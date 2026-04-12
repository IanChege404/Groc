export default function AnalyticsPage() {
  const metrics = [
    { label: 'Total Revenue', value: 'KES 0', trend: '+0%', positive: true },
    { label: 'Orders This Month', value: '0', trend: '+0%', positive: true },
    { label: 'New Users', value: '0', trend: '+0%', positive: true },
    { label: 'Avg. Order Value', value: 'KES 0', trend: '0%', positive: true },
  ];

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-gray-800 mb-6">Analytics</h1>

      {/* Key Metrics */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {metrics.map((m) => (
          <div
            key={m.label}
            className="bg-white rounded-xl p-5 shadow-sm border border-gray-100"
          >
            <p className="text-sm text-gray-500">{m.label}</p>
            <p className="text-2xl font-bold text-gray-800 mt-1">{m.value}</p>
            <span
              className={`text-xs font-medium ${m.positive ? 'text-green-600' : 'text-red-500'}`}
            >
              {m.trend}
            </span>
          </div>
        ))}
      </div>

      {/* Charts placeholder */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <h3 className="font-semibold text-gray-800 mb-4">
            Revenue Over Time
          </h3>
          <div className="h-48 flex items-center justify-center text-gray-400">
            Chart will render with live Firestore data
          </div>
        </div>
        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <h3 className="font-semibold text-gray-800 mb-4">
            Popular Products
          </h3>
          <div className="h-48 flex items-center justify-center text-gray-400">
            Chart will render with live Firestore data
          </div>
        </div>
      </div>
    </div>
  );
}
