import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions";
import {onRequest} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";

setGlobalOptions({maxInstances: 10});

if (!admin.apps.length) {
	admin.initializeApp();
}

const db = admin.firestore();

type PaymentStatus = "pending" | "processing" | "completed" | "failed";

interface PaymentRecord {
	paymentId: string;
	orderId: string;
	amount: number;
	currency: string;
	phoneNumber: string;
	status: PaymentStatus;
	provider: "mpesa";
	checkoutRequestId: string;
	merchantRequestId: string;
	createdAt: admin.firestore.FieldValue;
	updatedAt: admin.firestore.FieldValue;
}

const ALLOWED_ORIGINS = [
	"*",
];

function setCorsHeaders(origin: string | undefined, response: {
	set: (name: string, value: string) => void;
}): void {
	const allowOrigin = ALLOWED_ORIGINS.includes("*") ? "*" : (origin ?? "");
	response.set("Access-Control-Allow-Origin", allowOrigin || "*");
	response.set("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
	response.set("Access-Control-Allow-Headers", "Content-Type,Authorization");
}

function normalizedPath(path: string): string {
	const safePath = path || "/";
	if (safePath.startsWith("/api/")) {
		return safePath.substring(4);
	}
	if (safePath === "/api") {
		return "/";
	}
	return safePath;
}

function normalizePhoneNumber(phoneRaw: string): string {
	const digits = phoneRaw.replace(/\D/g, "");
	if (digits.startsWith("254")) {
		return digits;
	}
	if (digits.startsWith("0")) {
		return `254${digits.substring(1)}`;
	}
	if (digits.length === 9) {
		return `254${digits}`;
	}
	return digits;
}

function parsePaymentStatusPath(path: string): {paymentId: string} | null {
	const match = path.match(/^\/payments\/([^/]+)\/status$/);
	if (!match || !match[1]) {
		return null;
	}
	return {paymentId: match[1]};
}

function parsePaymentConfirmPath(path: string): {paymentId: string} | null {
	const match = path.match(/^\/payments\/([^/]+)\/confirm$/);
	if (!match || !match[1]) {
		return null;
	}
	return {paymentId: match[1]};
}

function badRequest(response: {
	status: (code: number) => {json: (value: unknown) => void};
}, message: string): void {
	response.status(400).json({
		success: false,
		message,
	});
}

export const api = onRequest({region: "us-central1"}, async (request, response) => {
	setCorsHeaders(request.headers.origin, response);

	if (request.method === "OPTIONS") {
		response.status(204).send("");
		return;
	}

	const path = normalizedPath(request.path);

	if (request.method === "GET" && (path === "/" || path === "/health")) {
		response.status(200).json({
			success: true,
			message: "Pro Grocery API is healthy",
			data: {
				service: "pro-grocery-functions",
				timestamp: new Date().toISOString(),
			},
		});
		return;
	}

	if (
		request.method === "POST" &&
		(path === "/payments/mpesa" || path === "/payments/initiate")
	) {
		const phoneNumberRaw = String(request.body?.phone_number ?? "").trim();
		const orderId = String(request.body?.order_id ?? "").trim();
		const amount = Number(request.body?.amount ?? 0);

		if (!phoneNumberRaw) {
			badRequest(response, "phone_number is required");
			return;
		}
		if (!orderId) {
			badRequest(response, "order_id is required");
			return;
		}
		if (!Number.isFinite(amount) || amount <= 0) {
			badRequest(response, "amount must be greater than 0");
			return;
		}

		const phoneNumber = normalizePhoneNumber(phoneNumberRaw);
		const nowMs = Date.now();
		const uniqueSuffix = Math.floor(Math.random() * 1e6).toString().padStart(6, "0");
		const paymentId = `mpesa_${nowMs}_${uniqueSuffix}`;
		const checkoutRequestId = `ws_CO_${nowMs}${uniqueSuffix}`;
		const merchantRequestId = `MR_${nowMs}${uniqueSuffix}`;

		const payload: PaymentRecord = {
			paymentId,
			orderId,
			amount,
			currency: "KES",
			phoneNumber,
			status: "processing",
			provider: "mpesa",
			checkoutRequestId,
			merchantRequestId,
			createdAt: admin.firestore.FieldValue.serverTimestamp(),
			updatedAt: admin.firestore.FieldValue.serverTimestamp(),
		};

		await db.collection("payments").doc(paymentId).set(payload);

		logger.info("M-Pesa payment initiated", {
			paymentId,
			orderId,
			amount,
		});

		response.status(200).json({
			success: true,
			message: "M-Pesa request initiated",
			data: {
				CheckoutRequestID: paymentId,
				ResponseCode: "0",
				ResponseDescription: "Success. Request accepted for processing",
				MerchantRequestID: merchantRequestId,
				CustomerMessage: "M-Pesa request sent. Complete on your phone.",
			},
		});
		return;
	}

	const statusPath = parsePaymentStatusPath(path);
	if (request.method === "GET" && statusPath) {
		const paymentDoc = await db.collection("payments").doc(statusPath.paymentId).get();
		if (!paymentDoc.exists) {
			response.status(404).json({
				success: false,
				message: "Payment not found",
			});
			return;
		}

		const data = paymentDoc.data() as {
			status?: PaymentStatus;
			amount?: number;
			currency?: string;
		};

		response.status(200).json({
			success: true,
			data: {
				payment_id: statusPath.paymentId,
				status: data.status ?? "pending",
				transaction_id: statusPath.paymentId,
				amount: data.amount ?? 0,
				currency: data.currency ?? "KES",
			},
		});
		return;
	}

	const confirmPath = parsePaymentConfirmPath(path);
	if (request.method === "POST" && confirmPath) {
		const statusRaw = String(request.body?.status ?? "completed").trim().toLowerCase();
		const nextStatus: PaymentStatus = statusRaw === "failed" ? "failed" : "completed";

		const paymentRef = db.collection("payments").doc(confirmPath.paymentId);
		const paymentDoc = await paymentRef.get();
		if (!paymentDoc.exists) {
			response.status(404).json({
				success: false,
				message: "Payment not found",
			});
			return;
		}

		await paymentRef.update({
			status: nextStatus,
			updatedAt: admin.firestore.FieldValue.serverTimestamp(),
		});

		response.status(200).json({
			success: true,
			message: `Payment marked as ${nextStatus}`,
			data: {
				payment_id: confirmPath.paymentId,
				status: nextStatus,
			},
		});
		return;
	}

	response.status(404).json({
		success: false,
		message: "Route not found",
	});
});
