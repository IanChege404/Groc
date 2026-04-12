import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Groc Admin Dashboard',
  description: 'Admin panel for managing the Groc grocery application',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-gray-50 min-h-screen">{children}</body>
    </html>
  );
}
