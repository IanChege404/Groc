export default function NotificationsPage() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-gray-800 mb-6">
        Push Notifications
      </h1>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Compose notification */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-lg font-semibold mb-4">Compose Notification</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Title
              </label>
              <input
                type="text"
                placeholder="Notification title"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Message
              </label>
              <textarea
                rows={4}
                placeholder="Notification message"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Topic
              </label>
              <select className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm">
                <option value="all">All Users</option>
                <option value="promotions">Promotions</option>
                <option value="deals">Flash Deals</option>
                <option value="orders">Order Updates</option>
              </select>
            </div>
            <button
              type="button"
              className="w-full bg-red-600 text-white py-2 rounded-lg hover:bg-red-700 transition-colors font-medium"
            >
              Send Notification
            </button>
          </div>
        </div>

        {/* Templates */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-lg font-semibold mb-4">Templates</h2>
          <div className="space-y-3">
            {[
              { name: 'Flash Deal Alert', topic: 'deals' },
              { name: 'Order Confirmed', topic: 'orders' },
              { name: 'Weekly Promotions', topic: 'promotions' },
              { name: 'Welcome Message', topic: 'all' },
            ].map((tpl) => (
              <div
                key={tpl.name}
                className="flex items-center justify-between p-3 border border-gray-100 rounded-lg hover:bg-gray-50"
              >
                <div>
                  <p className="font-medium text-sm">{tpl.name}</p>
                  <p className="text-xs text-gray-500">Topic: {tpl.topic}</p>
                </div>
                <button
                  type="button"
                  className="text-red-600 text-sm font-medium hover:underline"
                >
                  Use
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
