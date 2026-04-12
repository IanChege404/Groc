export default function AdminDashboard() {
  const stats = [
    { label: 'Total Revenue', value: 'KES 0', icon: '💰', color: 'bg-green-100 text-green-700' },
    { label: 'Total Orders', value: '0', icon: '🛒', color: 'bg-blue-100 text-blue-700' },
    { label: 'Total Users', value: '0', icon: '👥', color: 'bg-purple-100 text-purple-700' },
    { label: 'Active Products', value: '0', icon: '📦', color: 'bg-orange-100 text-orange-700' },
  ];

  const navLinks = [
    { href: '/products', label: 'Products', icon: '📦' },
    { href: '/orders', label: 'Orders', icon: '🛒' },
    { href: '/users', label: 'Users', icon: '👥' },
    { href: '/coupons', label: 'Coupons', icon: '🏷️' },
    { href: '/notifications', label: 'Notifications', icon: '🔔' },
    { href: '/analytics', label: 'Analytics', icon: '📊' },
  ];

  return (
    <div className="flex min-h-screen">
      {/* Sidebar */}
      <aside className="w-64 bg-white shadow-sm border-r border-gray-200 p-6">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-red-600">🛒 Groc Admin</h1>
          <p className="text-sm text-gray-500 mt-1">Management Dashboard</p>
        </div>
        <nav className="space-y-2">
          {navLinks.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-700 hover:bg-red-50 hover:text-red-600 transition-colors"
            >
              <span>{link.icon}</span>
              <span className="font-medium">{link.label}</span>
            </a>
          ))}
        </nav>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-8">
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-800">Dashboard Overview</h2>
          <p className="text-gray-500 mt-1">Welcome to the Groc Admin Panel</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {stats.map((stat) => (
            <div
              key={stat.label}
              className="bg-white rounded-xl p-6 shadow-sm border border-gray-100"
            >
              <div className={`inline-flex items-center justify-center w-12 h-12 rounded-lg ${stat.color} mb-4 text-2xl`}>
                {stat.icon}
              </div>
              <p className="text-sm text-gray-500">{stat.label}</p>
              <p className="text-2xl font-bold text-gray-800 mt-1">{stat.value}</p>
            </div>
          ))}
        </div>

        {/* Quick Actions */}
        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Quick Actions</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { label: 'Add Product', href: '/products/new', color: 'bg-blue-500' },
              { label: 'Create Coupon', href: '/coupons/new', color: 'bg-green-500' },
              { label: 'Send Notification', href: '/notifications/new', color: 'bg-purple-500' },
              { label: 'View Analytics', href: '/analytics', color: 'bg-orange-500' },
            ].map((action) => (
              <a
                key={action.label}
                href={action.href}
                className={`${action.color} text-white rounded-lg px-4 py-3 text-center text-sm font-medium hover:opacity-90 transition-opacity`}
              >
                {action.label}
              </a>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
