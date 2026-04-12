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

interface Config {
  mapFilePath: string;
  dryRun: boolean;
  reset: boolean;
  projectId?: string;
}

function parseArgs(argv: string[]): Config {
  let mapFilePath = path.resolve("../.cloudinary-map.json");
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
  console.log("Firestore admin seeder (categories/products/bundles)");
  console.log("Usage: npm --prefix functions run seed:firestore -- [options]");
  console.log("Options:");
  console.log("  --dry-run              Validate and print summary only");
  console.log("  --reset                Delete existing categories/products/bundles first");
  console.log("  --map-file=<path>      Path to .cloudinary-map.json");
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
      console.warn(`Warning: duplicate Cloudinary fileName \"${key}\" with different URLs. Keeping first.`);
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

async function maybeReset(db: admin.firestore.Firestore, reset: boolean): Promise<void> {
  if (!reset) return;

  console.log("Reset enabled: deleting existing categories/products/bundles ...");
  const targets = ["categories", "products", "bundles"];

  for (const col of targets) {
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

  const products = productSeeds.map((item) => ({
    id: item.id,
    data: {
      name: item.name,
      description: item.description,
      category: item.category,
      categoryId: item.categoryId,
      price: item.price,
      mainPrice: item.mainPrice,
      stock: item.stock,
      image: imageUrl(cloudinary, item.imageFileName),
      images: [imageUrl(cloudinary, item.imageFileName)],
      rating: item.rating,
      reviewCount: item.reviewCount,
      weight: item.weight,
      createdAt: now,
      updatedAt: now,
    },
  }));

  const productIdSet = new Set(products.map((item) => item.id));
  for (const bundle of bundleSeeds) {
    for (const productId of bundle.productIds) {
      if (!productIdSet.has(productId)) {
        throw new Error(`Bundle ${bundle.id} references unknown productId: ${productId}`);
      }
    }
  }

  const bundles = bundleSeeds.map((item) => ({
    id: item.id,
    data: {
      name: item.name,
      description: item.description,
      image: imageUrl(cloudinary, item.imageFileName),
      images: [imageUrl(cloudinary, item.imageFileName)],
      itemNames: item.itemNames,
      productIds: item.productIds,
      price: item.price,
      mainPrice: item.mainPrice,
      rating: item.rating,
      reviewCount: item.reviewCount,
      createdAt: now,
      updatedAt: now,
    },
  }));

  console.log("Seed preview:");
  console.log(`  - categories: ${categories.length}`);
  console.log(`  - products:   ${products.length}`);
  console.log(`  - bundles:    ${bundles.length}`);
  console.log(`  - map file:   ${config.mapFilePath}`);
  console.log(`  - mode:       ${config.dryRun ? "dry-run" : "write"}`);

  if (config.dryRun) {
    await app.delete();
    return;
  }

  await maybeReset(db, config.reset);

  console.log("Writing categories ...");
  for (const item of categories) {
    await db.collection("categories").doc(item.id).set(item.data, {merge: true});
  }

  console.log("Writing products ...");
  for (const item of products) {
    await db.collection("products").doc(item.id).set(item.data, {merge: true});
  }

  console.log("Writing bundles ...");
  for (const item of bundles) {
    await db.collection("bundles").doc(item.id).set(item.data, {merge: true});
  }

  // Seed recipes collection
  console.log("Writing recipes ...");
  const recipeSeeds = [
    {
      id: "recipe_001",
      data: {
        name: "Kenyan Beef Stew",
        description: "A hearty traditional Kenyan beef stew with potatoes and carrots.",
        imageUrl: "",
        servings: 4,
        prepTimeMinutes: 15,
        cookTimeMinutes: 60,
        difficulty: "medium",
        ingredients: [
          {productId: "beef_001", productName: "Beef (500g)", quantity: 1, unit: "pack"},
          {productId: "potato_001", productName: "Potatoes", quantity: 4, unit: "pieces"},
          {productId: "carrot_001", productName: "Carrots", quantity: 3, unit: "pieces"},
          {productId: "tomato_001", productName: "Tomatoes", quantity: 3, unit: "pieces"},
          {productId: "onion_001", productName: "Onions", quantity: 2, unit: "pieces"},
        ],
        instructions: [
          "Cut beef into cubes and season with salt and pepper.",
          "Heat oil in a large pot and brown the beef in batches.",
          "Add onions and cook until softened.",
          "Add tomatoes and cook for 5 minutes.",
          "Add potatoes and carrots, cover with water.",
          "Simmer for 45 minutes until meat and vegetables are tender.",
        ],
        tags: ["kenyan", "beef", "stew", "dinner"],
        rating: 4.5,
        reviewCount: 24,
        createdAt: now,
      },
    },
    {
      id: "recipe_002",
      data: {
        name: "Githeri Special",
        description: "Classic Kenyan mixed beans and maize dish.",
        imageUrl: "",
        servings: 6,
        prepTimeMinutes: 10,
        cookTimeMinutes: 90,
        difficulty: "easy",
        ingredients: [
          {productId: "maize_001", productName: "Maize (dried)", quantity: 2, unit: "cups"},
          {productId: "beans_001", productName: "Beans (mixed)", quantity: 2, unit: "cups"},
          {productId: "tomato_001", productName: "Tomatoes", quantity: 2, unit: "pieces"},
          {productId: "onion_001", productName: "Onions", quantity: 1, unit: "piece"},
        ],
        instructions: [
          "Soak maize and beans overnight.",
          "Boil together for 60–90 minutes until tender.",
          "Fry onions and tomatoes in oil.",
          "Add the boiled githeri and mix well.",
          "Season with salt and serve hot.",
        ],
        tags: ["kenyan", "vegetarian", "beans", "maize", "lunch"],
        rating: 4.3,
        reviewCount: 18,
        createdAt: now,
      },
    },
  ];

  for (const recipe of recipeSeeds) {
    await db.collection("recipes").doc(recipe.id).set(recipe.data, {merge: true});
  }

  // Seed flash deals (offers collection)
  console.log("Writing flash deals ...");
  const startTime = admin.firestore.Timestamp.fromDate(new Date());
  const endTime = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 48 * 60 * 60 * 1000), // 48 hours from now
  );

  const flashDeals = [
    {
      id: "deal_001",
      data: {
        productId: "prod_tomato",
        productName: "Fresh Tomatoes 1kg",
        imageUrl: "",
        originalPrice: 150,
        dealPrice: 90,
        discountPercentage: 40,
        stockLeft: 50,
        totalStock: 100,
        startTime,
        endTime,
        isActive: true,
        categoryId: "cat_vegetables",
      },
    },
    {
      id: "deal_002",
      data: {
        productId: "prod_milk",
        productName: "Fresh Whole Milk 1L",
        imageUrl: "",
        originalPrice: 80,
        dealPrice: 60,
        discountPercentage: 25,
        stockLeft: 30,
        totalStock: 80,
        startTime,
        endTime,
        isActive: true,
        categoryId: "cat_dairy",
      },
    },
  ];

  for (const deal of flashDeals) {
    await db.collection("offers").doc(deal.id).set(deal.data, {merge: true});
  }

  console.log("Seeding completed successfully.");
  await app.delete();
}

run().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`Seed failed: ${message}`);
  process.exit(1);
});
