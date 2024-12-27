import type { Metadata } from "next";
import { JetBrains_Mono } from "next/font/google";
import "./globals.css";

const jetbrainsMono = JetBrains_Mono({ 
  subsets: ["latin"],
  weight: ["400", "700"],
  preload: true,
  display: 'swap',
  variable: '--font-jetbrains',
  fallback: ['system-ui', 'arial'],
});

export const metadata: Metadata = {
  title: "Visit Counter",
  description: "cloud challenge application",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={jetbrainsMono.variable}>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </head>
      <body className={`${jetbrainsMono.className} antialiased`}>
        {children}
      </body>
    </html>
  );
}
