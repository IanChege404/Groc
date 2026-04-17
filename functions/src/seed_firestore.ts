import * as admin from "firebase-admin";
import * as fs from "node:fs";
import * as path from "node:path";

interface CloudinaryEntry {
  fileName: string;
  secureUrl: string;
}

interface CloudinaryMapPayload {
  entries: CloudinaryEntry[];
}

interface SeedCategory {
  id: string;
  name: string;
  description: string;
  iconFileName: string;
  color: string;
}

interface SeedProduct {
  id: string;
  name: string;
  description: string;
  categoryId: string;
  category: string;
  price: number;
  mainPrice: number;
  stock: number;
  imageFileName: string;
  rating: number;
  reviewCount: number;
  weight: string;
}

interface SeedBundle {
  id: string;
  name: string;
  description: string;
  imageFileName: string;
  itemNames: string[];
  productIds: string[];
  price: number;
  mainPrice: number;
  rating: number;
  reviewCount: number;
}

interface SeedRecipeIngredient {
  productId: string;
  productName: string;
  quantity: number;
  unit: string;
  imageFileName?: string;
  price?: number;
}

interface SeedRecipe {
  id: string;
  name: string;
  description: string;
  imageFileName: string;
  servings: number;
  prepTimeMinutes: number;
  cookTimeMinutes: number;
  difficulty: "easy" | "medium" | "hard";
  ingredients: SeedRecipeIngredient[];
  instructions: string[];
  tags: string[];
  rating: number;
  reviewCount: number;
}

interface SeedOffer {
  id: string;
  productId: string;
  productName: string;
  imageFileName: string;
  originalPrice: number;
  dealPrice: number;
  discountPercentage: number;
  stockLeft: number;
  totalStock: number;
  categoryId: string;
  startsInHours?: number;
  endsInHours: number;
  isActive: boolean;
}

interface SeedCoupon {
  id: string;
  code: string;
  title: string;
  discount: number;
  discountType: "percentage" | "fixed";
  expiresInDays: number;
  isUsed?: boolean;
  applicableCategories: string[];
  description?: string;
  minPurchaseAmount?: number;
  maxDiscount?: number;
  imageFileName: string;
}

interface SeedOnboarding {
  id: string;
  headline: string;
  description: string;
  imageUrl: string;
}

interface SeedDrawerMenuItem {
  id: string;
  label: string;
  route?: string;
}

interface Config {
  mapFilePath: string;
  dryRun: boolean;
  reset: boolean;
  projectId?: string;
}

const RESET_COLLECTIONS = [
  "categories",
  "products",
  "bundles",
  "recipes",
  "offers",
  "coupons",
  "onboarding",
  "drawer_menu",
  "top_questions",
  "help_topics",
  "app_content",
] as const;

function parseArgs(argv: string[]): Config {
  let mapFilePath = path.resolve(process.cwd(), ".cloudinary-map.json");
  let dryRun = false;
  let reset = false;
  let projectId: string | undefined;

  for (const arg of argv) {
    if (arg === "--dry-run") {
      dryRun = true;
      continue;
    }
    if (arg === "--reset") {
      reset = true;
      continue;
    }
    if (arg.startsWith("--map-file=")) {
      mapFilePath = path.resolve(arg.substring("--map-file=".length));
      continue;
    }
    if (arg.startsWith("--project-id=")) {
      projectId = arg.substring("--project-id=".length).trim();
      continue;
    }
    if (arg === "--help" || arg === "-h") {
      printUsage();
      process.exit(0);
    }

    throw new Error(`Unknown argument: ${arg}`);
  }

  return {mapFilePath, dryRun, reset, projectId};
}

function printUsage(): void {
  console.log("Firestore admin seeder (catalog + content)");
  console.log("Usage: npm --prefix functions run seed:firestore -- [options]");
  console.log("Options:");
  console.log("  --dry-run              Validate and print summary only");
  console.log("  --reset                Delete all seeded collections first");
  console.log("  --map-file=<path>      Absolute/relative path to .cloudinary-map.json");
  console.log("  --project-id=<id>      Override Firebase project ID");
  console.log("  --help, -h             Show help");
}

function loadCloudinaryMap(filePath: string): Map<string, string> {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Cloudinary map file not found: ${filePath}`);
  }

  const raw = fs.readFileSync(filePath, "utf8");
  const decoded = JSON.parse(raw) as CloudinaryMapPayload;
  if (!Array.isArray(decoded.entries)) {
    throw new Error(`Invalid map format in ${filePath}: entries array missing`);
  }

  const byFileName = new Map<string, string>();
  for (const entry of decoded.entries) {
    if (!entry?.fileName || !entry?.secureUrl) continue;

    const key = entry.fileName.toLowerCase();
    if (byFileName.has(key) && byFileName.get(key) !== entry.secureUrl) {
      console.warn(
        `Warning: duplicate Cloudinary fileName "${key}" with different URLs. Keeping first.`,
      );
      continue;
    }

    byFileName.set(key, entry.secureUrl);
  }

  return byFileName;
}

function imageUrl(map: Map<string, string>, fileName: string): string {
  const url = map.get(fileName.toLowerCase());
  if (!url) {
    throw new Error(`Missing Cloudinary URL for required image: ${fileName}`);
  }
  return url;
}

function assertReference(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

const categorySeeds: SeedCategory[] = [
  {
    id: "category_dairy_eggs",
    name: "Dairy & Eggs",
    description: "Fresh milk, yogurt, cheese, and eggs",
    iconFileName: "app_logo.png",
    color: "#E8F5E9",
  },
  {
    id: "category_bakery",
    name: "Bakery",
    description: "Fresh bread, pastries, and baked goods",
    iconFileName: "app_logo.png",
    color: "#FFF3E0",
  },
  {
    id: "category_frozen_foods",
    name: "Frozen Foods",
    description: "Ice cream, frozen vegetables, and frozen meals",
    iconFileName: "app_logo.png",
    color: "#E1F5FE",
  },
  {
    id: "category_pantry_staples",
    name: "Pantry Staples",
    description: "Oil, salt, spices, and cooking essentials",
    iconFileName: "app_logo.png",
    color: "#FCE4EC",
  },
  {
    id: "category_meat_seafood",
    name: "Meat & Seafood",
    description: "Fresh meat, poultry, and seafood",
    iconFileName: "app_logo.png",
    color: "#F3E5F5",
  },
];

const productSeeds: SeedProduct[] = [
  {
    id: "product_perrys_ice_cream_banana_800gm",
    name: "Perry's Ice Cream Banana",
    description: "Delicious banana-flavored ice cream by Perry's, perfect for dessert",
    categoryId: "category_frozen_foods",
    category: "Frozen Foods",
    price: 13,
    mainPrice: 15,
    stock: 45,
    imageFileName: "app_logo.png",
    rating: 4.5,
    reviewCount: 128,
    weight: "800 gm",
  },
  {
    id: "product_vanilla_ice_cream_banana_500gm",
    name: "Vanilla Ice Cream Banana",
    description: "Classic vanilla ice cream with banana flavor, smooth and creamy",
    categoryId: "category_frozen_foods",
    category: "Frozen Foods",
    price: 12,
    mainPrice: 15,
    stock: 32,
    imageFileName: "app_logo.png",
    rating: 4.3,
    reviewCount: 95,
    weight: "500 gm",
  },
  {
    id: "product_premium_meat_selection_1kg",
    name: "Premium Meat Selection",
    description: "High-quality fresh meat, vacuum-sealed for optimal freshness",
    categoryId: "category_meat_seafood",
    category: "Meat & Seafood",
    price: 15,
    mainPrice: 18,
    stock: 28,
    imageFileName: "app_logo.png",
    rating: 4.7,
    reviewCount: 156,
    weight: "1 Kg",
  },
  {
    id: "product_organic_onions_1kg",
    name: "Organic Onions",
    description: "Fresh organic onions, locally sourced and pesticide-free",
    categoryId: "category_pantry_staples",
    category: "Pantry Staples",
    price: 3.5,
    mainPrice: 5,
    stock: 120,
    imageFileName: "coupon_background_1.png",
    rating: 4.2,
    reviewCount: 42,
    weight: "1 Kg",
  },
  {
    id: "product_fresh_tomatoes_1kg",
    name: "Fresh Tomatoes",
    description: "Ripe fresh tomatoes perfect for stews, sauces, and salads",
    categoryId: "category_pantry_staples",
    category: "Pantry Staples",
    price: 5,
    mainPrice: 6.5,
    stock: 110,
    imageFileName: "coupon_background_2.png",
    rating: 4.4,
    reviewCount: 74,
    weight: "1 Kg",
  },
  {
    id: "product_premium_cooking_oil_1litre",
    name: "Premium Cooking Oil",
    description: "Pure vegetable oil, ideal for cooking and baking",
    categoryId: "category_pantry_staples",
    category: "Pantry Staples",
    price: 8.5,
    mainPrice: 10,
    stock: 67,
    imageFileName: "coupon_background_2.png",
    rating: 4.6,
    reviewCount: 89,
    weight: "1 Litre",
  },
  {
    id: "product_sea_salt_premium_grade_500gm",
    name: "Sea Salt - Premium Grade",
    description: "Fine white sea salt for cooking and seasoning",
    categoryId: "category_pantry_staples",
    category: "Pantry Staples",
    price: 2.5,
    mainPrice: 3.5,
    stock: 200,
    imageFileName: "coupon_background_3.png",
    rating: 4.4,
    reviewCount: 73,
    weight: "500 gm",
  },
  {
    id: "product_mixed_spice_collection_250gm",
    name: "Mixed Spice Collection",
    description: "Assorted premium spices for authentic cooking",
    categoryId: "category_pantry_staples",
    category: "Pantry Staples",
    price: 12,
    mainPrice: 15,
    stock: 55,
    imageFileName: "coupon_background_4.png",
    rating: 4.8,
    reviewCount: 167,
    weight: "250 gm",
  },
  {
    id: "product_fresh_whole_milk_1litre",
    name: "Fresh Whole Milk",
    description: "Fresh whole milk, pasteurized and homogenized",
    categoryId: "category_dairy_eggs",
    category: "Dairy & Eggs",
    price: 3.2,
    mainPrice: 4,
    stock: 89,
    imageFileName: "profile_page_background.png",
    rating: 4.5,
    reviewCount: 134,
    weight: "1 Litre",
  },
];

const bundleSeeds: SeedBundle[] = [
  {
    id: "bundle_essential_cooking_pack",
    name: "Essential Cooking Bundle Pack",
    description: "Everything you need for basic cooking: onions, oil, and salt",
    imageFileName: "coupon_background_1.png",
    itemNames: ["Onion 1Kg", "Cooking Oil 1L", "Sea Salt 500gm"],
    productIds: [
      "product_organic_onions_1kg",
      "product_premium_cooking_oil_1litre",
      "product_sea_salt_premium_grade_500gm",
    ],
    price: 12.5,
    mainPrice: 16.5,
    rating: 4.6,
    reviewCount: 234,
  },
  {
    id: "bundle_premium_spices",
    name: "Premium Spices Bundle",
    description: "Complete spice collection for exotic and traditional dishes",
    imageFileName: "coupon_background_2.png",
    itemNames: ["Mixed Spices 250gm", "Cooking Oil 1L"],
    productIds: [
      "product_mixed_spice_collection_250gm",
      "product_premium_cooking_oil_1litre",
    ],
    price: 18,
    mainPrice: 22,
    rating: 4.7,
    reviewCount: 156,
  },
  {
    id: "bundle_frozen_dessert",
    name: "Frozen Dessert Bundle",
    description: "Ice cream treats for the whole family",
    imageFileName: "coupon_background_3.png",
    itemNames: ["Perry's Ice Cream 800gm", "Vanilla Ice Cream 500gm"],
    productIds: [
      "product_perrys_ice_cream_banana_800gm",
      "product_vanilla_ice_cream_banana_500gm",
    ],
    price: 22,
    mainPrice: 28,
    rating: 4.8,
    reviewCount: 289,
  },
  {
    id: "bundle_complete_breakfast",
    name: "Complete Breakfast Bundle",
    description: "Fresh dairy products for a complete breakfast",
    imageFileName: "coupon_background_4.png",
    itemNames: ["Fresh Milk 1L", "Mixed Spices 250gm"],
    productIds: [
      "product_fresh_whole_milk_1litre",
      "product_mixed_spice_collection_250gm",
    ],
    price: 13.5,
    mainPrice: 17,
    rating: 4.5,
    reviewCount: 198,
  },
];

const recipeSeeds: SeedRecipe[] = [
  {
    id: "recipe_001",
    name: "Kenyan Beef Stew",
    description: "A hearty traditional Kenyan beef stew with tomatoes and onions.",
    imageFileName: "coupon_background_3.png",
    servings: 4,
    prepTimeMinutes: 15,
    cookTimeMinutes: 60,
    difficulty: "medium",
    ingredients: [
      {
        productId: "product_premium_meat_selection_1kg",
        productName: "Premium Meat Selection (500g)",
        quantity: 1,
        unit: "pack",
        imageFileName: "app_logo.png",
        price: 15,
      },
      {
        productId: "product_fresh_tomatoes_1kg",
        productName: "Fresh Tomatoes",
        quantity: 3,
        unit: "pieces",
        imageFileName: "coupon_background_2.png",
        price: 5,
      },
      {
        productId: "product_organic_onions_1kg",
        productName: "Organic Onions",
        quantity: 2,
        unit: "pieces",
        imageFileName: "coupon_background_1.png",
        price: 3.5,
      },
      {
        productId: "product_sea_salt_premium_grade_500gm",
        productName: "Sea Salt",
        quantity: 1,
        unit: "tbsp",
        imageFileName: "coupon_background_3.png",
        price: 2.5,
      },
    ],
    instructions: [
      "Cut beef into cubes and season with salt and pepper.",
      "Heat oil in a large pot and brown the beef in batches.",
      "Add onions and cook until softened.",
      "Add tomatoes and cook for 5 minutes.",
      "Add water and simmer for 45 minutes until tender.",
    ],
    tags: ["kenyan", "beef", "stew", "dinner"],
    rating: 4.5,
    reviewCount: 24,
  },
  {
    id: "recipe_002",
    name: "Spiced Tomato Onion Mix",
    description: "Quick tomato-onion base for stews, rice, and vegetable dishes.",
    imageFileName: "coupon_background_4.png",
    servings: 3,
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    difficulty: "easy",
    ingredients: [
      {
        productId: "product_fresh_tomatoes_1kg",
        productName: "Fresh Tomatoes",
        quantity: 4,
        unit: "pieces",
        imageFileName: "coupon_background_2.png",
        price: 5,
      },
      {
        productId: "product_organic_onions_1kg",
        productName: "Organic Onions",
        quantity: 2,
        unit: "pieces",
        imageFileName: "coupon_background_1.png",
        price: 3.5,
      },
      {
        productId: "product_mixed_spice_collection_250gm",
        productName: "Mixed Spice Collection",
        quantity: 1,
        unit: "tbsp",
        imageFileName: "coupon_background_4.png",
        price: 12,
      },
    ],
    instructions: [
      "Slice onions and tomatoes.",
      "Saute onions in a little oil until translucent.",
      "Add tomatoes and cook until soft.",
      "Stir in mixed spices and simmer for 5 minutes.",
    ],
    tags: ["kenyan", "vegetarian", "sauce", "lunch"],
    rating: 4.3,
    reviewCount: 18,
  },
];

const offerSeeds: SeedOffer[] = [
  {
    id: "deal_001",
    productId: "product_fresh_tomatoes_1kg",
    productName: "Fresh Tomatoes 1kg",
    imageFileName: "coupon_background_2.png",
    originalPrice: 6.5,
    dealPrice: 5,
    discountPercentage: 23,
    stockLeft: 50,
    totalStock: 100,
    categoryId: "category_pantry_staples",
    startsInHours: 0,
    endsInHours: 48,
    isActive: true,
  },
  {
    id: "deal_002",
    productId: "product_fresh_whole_milk_1litre",
    productName: "Fresh Whole Milk 1L",
    imageFileName: "profile_page_background.png",
    originalPrice: 4,
    dealPrice: 3.2,
    discountPercentage: 20,
    stockLeft: 30,
    totalStock: 80,
    categoryId: "category_dairy_eggs",
    startsInHours: 0,
    endsInHours: 48,
    isActive: true,
  },
];

const couponSeeds: SeedCoupon[] = [
  {
    id: "coupon_welcome_10",
    code: "WELCOME10",
    title: "10% Off Welcome Coupon",
    discount: 10,
    discountType: "percentage",
    expiresInDays: 90,
    applicableCategories: ["category_pantry_staples", "category_dairy_eggs"],
    description: "Get 10% off your first order.",
    minPurchaseAmount: 20,
    maxDiscount: 5,
    imageFileName: "coupon_background_1.png",
  },
  {
    id: "coupon_dairy_5",
    code: "DAIRY5",
    title: "Save 5 on Dairy",
    discount: 5,
    discountType: "fixed",
    expiresInDays: 60,
    applicableCategories: ["category_dairy_eggs"],
    description: "Flat 5 off on dairy purchases above 15.",
    minPurchaseAmount: 15,
    imageFileName: "coupon_background_2.png",
  },
];

const onboardingSeeds: SeedOnboarding[] = [
  {
    id: "onboarding_001",
    headline: "Browse all the category",
    description: "In aliquip aute exercitation ut et nisi ut mollit. Deserunt dolor elit pariatur aute .",
    imageUrl: "https://i.imgur.com/X2G11k0.png",
  },
  {
    id: "onboarding_002",
    headline: "Amazing Discounts & Offers",
    description: "In aliquip aute exercitation ut et nisi ut mollit. Deserunt dolor elit pariatur aute .",
    imageUrl: "https://i.imgur.com/sMLlh1i.png",
  },
  {
    id: "onboarding_003",
    headline: "Delivery in 30 Min",
    description: "In aliquip aute exercitation ut et nisi ut mollit. Deserunt dolor elit pariatur aute .",
    imageUrl: "https://i.imgur.com/lHlOUT5.png",
  },
];

const drawerMenuSeeds: SeedDrawerMenuItem[] = [
  {id: "drawer_001", label: "Invite Friend"},
  {id: "drawer_002", label: "About Us", route: "aboutUs"},
  {id: "drawer_003", label: "FAQs", route: "faq"},
  {id: "drawer_004", label: "Terms & Conditions", route: "termsAndConditions"},
  {id: "drawer_005", label: "Help Center", route: "help"},
  {id: "drawer_006", label: "Rate This App"},
  {id: "drawer_007", label: "Privacy Policy"},
  {id: "drawer_008", label: "Contact Us", route: "contactUs"},
  {id: "drawer_009", label: "Logout", route: "introLogin"},
];

const topQuestions = [
  "How do I return my Items",
  "How to use collection point?",
  "What is Grocery?",
  "How can i add new delivery address?",
  "How can i avail Sticker Price?",
];

const helpTopics = [
  "My Account",
  "Payment and Wallet",
  "Shipping & Delivery",
  "Vouchers & Promotions",
  "Ordering",
];

async function maybeReset(db: admin.firestore.Firestore, reset: boolean): Promise<void> {
  if (!reset) return;

  console.log("Reset enabled: deleting all seeded collections ...");

  for (const col of RESET_COLLECTIONS) {
    const snapshot = await db.collection(col).get();
    if (snapshot.empty) continue;

    const batchSize = 400;
    const docs = snapshot.docs;
    for (let index = 0; index < docs.length; index += batchSize) {
      const batch = db.batch();
      const chunk = docs.slice(index, index + batchSize);
      for (const doc of chunk) {
        batch.delete(doc.ref);
      }
      await batch.commit();
    }

    console.log(`  - deleted ${docs.length} docs from ${col}`);
  }
}

async function writeCollection(
  db: admin.firestore.Firestore,
  collection: string,
  docs: Array<{id: string; data: Record<string, unknown>}>,
): Promise<void> {
  console.log(`Writing ${collection} ...`);
  for (const item of docs) {
    await db.collection(collection).doc(item.id).set(item.data, {merge: true});
  }
}

async function run(): Promise<void> {
  const config = parseArgs(process.argv.slice(2));
  const cloudinary = loadCloudinaryMap(config.mapFilePath);

  const app = admin.initializeApp(
    config.projectId ? {projectId: config.projectId} : undefined,
  );

  const db = app.firestore();
  const now = admin.firestore.Timestamp.now();

  const categories = categorySeeds.map((item) => ({
    id: item.id,
    data: {
      name: item.name,
      description: item.description,
      icon: imageUrl(cloudinary, item.iconFileName),
      color: item.color,
      createdAt: now,
    },
  }));

  const categoryIdSet = new Set(categories.map((item) => item.id));

  const products = productSeeds.map((item) => {
    assertReference(
      categoryIdSet.has(item.categoryId),
      `Product ${item.id} references unknown categoryId: ${item.categoryId}`,
    );

    const productImage = imageUrl(cloudinary, item.imageFileName);
    return {
      id: item.id,
      data: {
        name: item.name,
        description: item.description,
        category: item.category,
        categoryId: item.categoryId,
        price: item.price,
        mainPrice: item.mainPrice,
        stock: item.stock,
        image: productImage,
        images: [productImage],
        rating: item.rating,
        reviewCount: item.reviewCount,
        weight: item.weight,
        createdAt: now,
        updatedAt: now,
      },
    };
  });

  const productIdSet = new Set(products.map((item) => item.id));

  for (const bundle of bundleSeeds) {
    for (const productId of bundle.productIds) {
      assertReference(
        productIdSet.has(productId),
        `Bundle ${bundle.id} references unknown productId: ${productId}`,
      );
    }
  }

  const bundles = bundleSeeds.map((item) => {
    const bundleImage = imageUrl(cloudinary, item.imageFileName);
    return {
      id: item.id,
      data: {
        name: item.name,
        description: item.description,
        image: bundleImage,
        images: [bundleImage],
        itemNames: item.itemNames,
        productIds: item.productIds,
        price: item.price,
        mainPrice: item.mainPrice,
        rating: item.rating,
        reviewCount: item.reviewCount,
        createdAt: now,
        updatedAt: now,
      },
    };
  });

  const recipes = recipeSeeds.map((item) => {
    for (const ingredient of item.ingredients) {
      assertReference(
        productIdSet.has(ingredient.productId),
        `Recipe ${item.id} references unknown ingredient productId: ${ingredient.productId}`,
      );
    }

    return {
      id: item.id,
      data: {
        name: item.name,
        description: item.description,
        imageUrl: imageUrl(cloudinary, item.imageFileName),
        servings: item.servings,
        prepTimeMinutes: item.prepTimeMinutes,
        cookTimeMinutes: item.cookTimeMinutes,
        difficulty: item.difficulty,
        ingredients: item.ingredients.map((ingredient) => ({
          productId: ingredient.productId,
          productName: ingredient.productName,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          imageUrl: ingredient.imageFileName ? imageUrl(cloudinary, ingredient.imageFileName) : null,
          price: ingredient.price ?? null,
        })),
        instructions: item.instructions,
        tags: item.tags,
        rating: item.rating,
        reviewCount: item.reviewCount,
        createdAt: now,
      },
    };
  });

  const offers = offerSeeds.map((deal) => {
    assertReference(
      productIdSet.has(deal.productId),
      `Offer ${deal.id} references unknown productId: ${deal.productId}`,
    );
    assertReference(
      categoryIdSet.has(deal.categoryId),
      `Offer ${deal.id} references unknown categoryId: ${deal.categoryId}`,
    );

    const startTime = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + (deal.startsInHours ?? 0) * 60 * 60 * 1000),
    );
    const endTime = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + deal.endsInHours * 60 * 60 * 1000),
    );

    return {
      id: deal.id,
      data: {
        productId: deal.productId,
        productName: deal.productName,
        imageUrl: imageUrl(cloudinary, deal.imageFileName),
        originalPrice: deal.originalPrice,
        dealPrice: deal.dealPrice,
        discountPercentage: deal.discountPercentage,
        stockLeft: deal.stockLeft,
        totalStock: deal.totalStock,
        startTime,
        endTime,
        isActive: deal.isActive,
        categoryId: deal.categoryId,
      },
    };
  });

  const coupons = couponSeeds.map((coupon) => {
    for (const categoryId of coupon.applicableCategories) {
      assertReference(
        categoryIdSet.has(categoryId),
        `Coupon ${coupon.id} references unknown applicable categoryId: ${categoryId}`,
      );
    }

    return {
      id: coupon.id,
      data: {
        code: coupon.code.toUpperCase(),
        title: coupon.title,
        discount: coupon.discount,
        discountType: coupon.discountType,
        expireDate: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + coupon.expiresInDays * 24 * 60 * 60 * 1000),
        ),
        isUsed: coupon.isUsed ?? false,
        applicableCategories: coupon.applicableCategories,
        description: coupon.description ?? null,
        minPurchaseAmount: coupon.minPurchaseAmount ?? null,
        maxDiscount: coupon.maxDiscount ?? null,
        imageUrl: imageUrl(cloudinary, coupon.imageFileName),
        createdAt: now,
      },
    };
  });

  const onboarding = onboardingSeeds.map((item, index) => ({
    id: item.id,
    data: {
      headline: item.headline,
      description: item.description,
      imageUrl: item.imageUrl,
      order: index,
      isActive: true,
      updatedAt: now,
    },
  }));

  const drawerMenu = drawerMenuSeeds.map((item, index) => ({
    id: item.id,
    data: {
      label: item.label,
      route: item.route ?? null,
      order: index,
      isActive: true,
      updatedAt: now,
    },
  }));

  const topQuestionsDocs = topQuestions.map((question, index) => ({
    id: `question_${String(index + 1).padStart(3, "0")}`,
    data: {
      question,
      order: index,
      isActive: true,
      updatedAt: now,
    },
  }));

  const helpTopicsDocs = helpTopics.map((topic, index) => ({
    id: `topic_${String(index + 1).padStart(3, "0")}`,
    data: {
      label: topic,
      order: index,
      isActive: true,
      updatedAt: now,
    },
  }));

  const appContent = [
    {
      id: "app_images",
      data: {
        logo: "https://i.imgur.com/9EsY2t6.png",
        homeBanner: "https://i.imgur.com/8hBIsS5.png",
        illustration404: "https://i.imgur.com/SGTzEiC.png",
        introBackground1: "https://i.imgur.com/YQ9twZx.png",
        introBackground2: "https://i.imgur.com/3hgB1or.png",
        numberVerification: "https://i.imgur.com/tCCmY3I.png",
        verified: "https://i.imgur.com/vF1jB6b.png",
        couponBackgrounds: [
          imageUrl(cloudinary, "coupon_background_1.png"),
          imageUrl(cloudinary, "coupon_background_2.png"),
          imageUrl(cloudinary, "coupon_background_3.png"),
          imageUrl(cloudinary, "coupon_background_4.png"),
        ],
        updatedAt: now,
      },
    },
    {
      id: "app_assets",
      data: {
        images: [
          imageUrl(cloudinary, "app_logo.png"),
          imageUrl(cloudinary, "coupon_background_1.png"),
          imageUrl(cloudinary, "coupon_background_2.png"),
          imageUrl(cloudinary, "coupon_background_3.png"),
          imageUrl(cloudinary, "coupon_background_4.png"),
          imageUrl(cloudinary, "profile_page_background.png"),
        ],
        directories: {
          fonts: "assets/fonts/",
          icons: "assets/icons/",
          images: "assets/images/",
        },
        updatedAt: now,
      },
    },
    {
      id: "faq",
      data: {
        items: [
          {
            title: "How it will take to delivery?",
            paragraph:
              "In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium.",
          },
          {
            title: "What is refund system?",
            paragraph:
              "In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium.",
          },
        ],
        updatedAt: now,
      },
    },
    {
      id: "contact_us",
      data: {
        phones: ["+8801710000000", "+8801710000000"],
        email: "jonarban45@gmail.com",
        address: "26/C Mohammadpur, Dhaka, Bangladesh",
        mapImageUrl: "https://i.imgur.com/nys3Bxw.png",
        updatedAt: now,
      },
    },
  ];

  console.log("Seed preview:");
  console.log(`  - categories:     ${categories.length}`);
  console.log(`  - products:       ${products.length}`);
  console.log(`  - bundles:        ${bundles.length}`);
  console.log(`  - recipes:        ${recipes.length}`);
  console.log(`  - offers:         ${offers.length}`);
  console.log(`  - coupons:        ${coupons.length}`);
  console.log(`  - onboarding:     ${onboarding.length}`);
  console.log(`  - drawer_menu:    ${drawerMenu.length}`);
  console.log(`  - top_questions:  ${topQuestionsDocs.length}`);
  console.log(`  - help_topics:    ${helpTopicsDocs.length}`);
  console.log(`  - app_content:    ${appContent.length}`);
  console.log(`  - map file:       ${config.mapFilePath}`);
  console.log(`  - mode:           ${config.dryRun ? "dry-run" : "write"}`);

  if (config.dryRun) {
    await app.delete();
    return;
  }

  await maybeReset(db, config.reset);

  await writeCollection(db, "categories", categories);
  await writeCollection(db, "products", products);
  await writeCollection(db, "bundles", bundles);
  await writeCollection(db, "recipes", recipes);
  await writeCollection(db, "offers", offers);
  await writeCollection(db, "coupons", coupons);
  await writeCollection(db, "onboarding", onboarding);
  await writeCollection(db, "drawer_menu", drawerMenu);
  await writeCollection(db, "top_questions", topQuestionsDocs);
  await writeCollection(db, "help_topics", helpTopicsDocs);
  await writeCollection(db, "app_content", appContent);

  console.log("Seeding completed successfully.");
  await app.delete();
}

run().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`Seed failed: ${message}`);
  process.exit(1);
});
