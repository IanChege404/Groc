'use client';

import { useFirestore } from '@/lib/hooks/useFirestore';
import { orderBy } from 'firebase/firestore';

interface Order {
  id: string;
  userId?: string;
  items?: { name: string; price: number; quantity: number }[];
  totalAmount?: number;
  status?: string;
  paymentMethod?: string;
  shippingAddress?: string;
  createdAt?: { seconds: number; nanoseconds: number };
}

function formatDate(ts?: { seconds: number; nanoseconds: number }): string {
  if (!ts) return 'N/A';
  return new Date(ts.seconds * 1000).toLocaleDateString('en-KE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

function statusBadge(status?: string) {
  const colors: Record<string, string> = {
    pending: 'bg-yellow-100 text-yellow-700',
    processing: 'bg-blue-100 text-blue-700',
    delivered: 'bg-green-100 text-green-700',
    cancelled: 'bg-red-100 text-red-700',
    shipped: 'bg-purple-100 text-purple-700',
  };
  const color = colors[status?.toLowerCase() || ''] || 'bg-gray-100 text-gray-700';
  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
      {status || 'Unknown'}
    </span>
  );
}

export default function OrdersPage() {
  const { data: orders, loading, error } = useFirestore<Order>('orders', [orderBy('createdAt', 'desc')]);

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-gray-800 mb-6">Orders</h1>
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        {error && (
          <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
            Error loading orders: {error}
          </div>
        )}
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead className="bg-gray-50 text-gray-600 uppercase text-xs">
              <tr>
                <th className="px-4 py-3">Order ID</th>
                <th className="px-4 py-3">Customer</th>
                <th className="px-4 py-3">Amount</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Payment</th>
                <th className="px-4 py-3">Date</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={6} className="text-center py-12 text-gray-500">
                    <div className="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-red-600 mb-2" />
                    <p>Loading orders...</p>
                  </td>
                </tr>
              ) : orders.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-12 text-gray-500">
                    No orders found.
                  </td>
                </tr>
              ) : (
                orders.map((order) => (
                  <tr key={order.id} className="border-t border-gray-100 hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-xs">{order.id.slice(0, 12)}...</td>
                    <td className="px-4 py-3">{order.userId?.slice(0, 12) || 'N/A'}...</td>
                    <td className="px-4 py-3 font-medium">
                      KES {(order.totalAmount || 0).toLocaleString()}
                    </td>
                    <td className="px-4 py-3">{statusBadge(order.status)}</td>
                    <td className="px-4 py-3">{order.paymentMethod || 'N/A'}</td>
                    <td className="px-4 py-3">{formatDate(order.createdAt)}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
        {!loading && orders.length > 0 && (
          <p className="text-xs text-gray-400 mt-4">Showing {orders.length} orders</p>
        )}
      </div>
    </div>
  );
}
