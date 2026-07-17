'use client';

import { useFirestore } from '@/lib/hooks/useFirestore';
import { orderBy } from 'firebase/firestore';

interface Product {
  id: string;
  name?: string;
  description?: string;
  category?: string;
  categoryId?: string;
  price?: number;
  mainPrice?: number;
  stock?: number;
  image?: string;
  rating?: number;
  reviewCount?: number;
}

export default function ProductsPage() {
  const { data: products, loading, error } = useFirestore<Product>('products', [orderBy('name', 'asc')]);

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Products</h1>
        <a
          href="/products/new"
          className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors"
        >
          + Add Product
        </a>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
          Error loading products: {error}
        </div>
      )}

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        {loading ? (
          <div className="text-center py-12 text-gray-500">
            <div className="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-red-600 mb-2" />
            <p>Loading products...</p>
          </div>
        ) : products.length === 0 ? (
          <p className="text-gray-500 text-center py-12">No products found.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm text-left">
              <thead className="bg-gray-50 text-gray-600 uppercase text-xs">
                <tr>
                  <th className="px-4 py-3">Product</th>
                  <th className="px-4 py-3">Category</th>
                  <th className="px-4 py-3">Price</th>
                  <th className="px-4 py-3">Stock</th>
                  <th className="px-4 py-3">Rating</th>
                  <th className="px-4 py-3">Actions</th>
                </tr>
              </thead>
              <tbody>
                {products.map((product) => (
                  <tr key={product.id} className="border-t border-gray-100 hover:bg-gray-50">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        {product.image ? (
                          <img
                            src={product.image}
                            alt={product.name || ''}
                            className="w-10 h-10 rounded-lg object-cover"
                          />
                        ) : (
                          <div className="w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center text-gray-400">
                            📦
                          </div>
                        )}
                        <div>
                          <p className="font-medium">{product.name || 'Unnamed'}</p>
                          <p className="text-xs text-gray-400 truncate max-w-[200px]">
                            {product.description || ''}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className="px-2 py-1 bg-gray-100 rounded-full text-xs font-medium text-gray-600">
                        {product.category || 'Uncategorized'}
                      </span>
                    </td>
                    <td className="px-4 py-3 font-medium">
                      KES {(product.price || product.mainPrice || 0).toLocaleString()}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        (product.stock || 0) > 0 ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                      }`}>
                        {product.stock || 0}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      {product.rating ? (
                        <span className="text-yellow-500">
                          ★ {product.rating.toFixed(1)} ({product.reviewCount || 0})
                        </span>
                      ) : (
                        <span className="text-gray-400 text-xs">No reviews</span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <button className="text-red-600 hover:text-red-700 text-xs font-medium">
                        Edit
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {!loading && products.length > 0 && (
          <p className="text-xs text-gray-400 mt-4">Showing {products.length} products</p>
        )}
      </div>
    </div>
  );
}
