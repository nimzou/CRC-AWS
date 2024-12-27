"use client";

import React, { useEffect, useRef, useState } from "react";
import { getViews } from "../api/getViews";

const Spotlight: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [viewCount, setViewCount] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Fetch view count
  useEffect(() => {
    const fetchViews = async () => {
      try {
        const views = await getViews();
        setViewCount(views);
        setError(null);
      } catch (err) {
        console.error('Failed to fetch views:', err);
        setError('Failed to load view count');
        setViewCount(null);
      }
    };

    fetchViews();
  }, []);

  useEffect(() => {
    const container = containerRef.current;
    if (!container || typeof window === 'undefined') return;

    const updateSpotlight = (x: number, y: number) => {
      container.style.setProperty("--mouse-x", `${x}%`);
      container.style.setProperty("--mouse-y", `${y}%`);
    };

    const handleInteraction = (e: MouseEvent | TouchEvent) => {
      const { left, top, width, height } = container.getBoundingClientRect();
      let x, y;

      if (e instanceof MouseEvent) {
        x = ((e.clientX - left) / width) * 100;
        y = ((e.clientY - top) / height) * 100;
      } else {
        e.preventDefault();
        const touch = e.touches[0];
        x = ((touch.clientX - left) / width) * 100;
        y = ((touch.clientY - top) / height) * 100;
      }

      updateSpotlight(x, y);
    };

    // Set initial position
    updateSpotlight(50, 50);

    container.addEventListener("mousemove", handleInteraction);
    container.addEventListener("touchmove", handleInteraction, { passive: false });

    return () => {
      container.removeEventListener("mousemove", handleInteraction);
      container.removeEventListener("touchmove", handleInteraction);
    };
  }, []);

  return (
    <div
      ref={containerRef}
      className="relative min-h-screen w-full bg-black overflow-hidden"
      style={{
        '--mouse-x': '50%',
        '--mouse-y': '50%',
      } as React.CSSProperties}
    >
      <div 
        className="absolute inset-0 transition-opacity duration-300"
        style={{
          background: 'radial-gradient(600px circle at var(--mouse-x) var(--mouse-y), rgba(255,255,255,0.06), transparent 40%)',
        }}
      />

      <div className="absolute inset-0 flex items-center justify-center p-4 md:p-8">
        <div className="relative group">
          <div className="absolute -inset-0.5 bg-gradient-to-b from-black to-purple-500 rounded-lg blur opacity-30 group-hover:opacity-50 transition duration-1000" />
          <div className="relative px-7 py-6 md:px-10 md:py-8 bg-black/50 backdrop-blur-xl rounded-lg border border-white/10">
            <div className="text-center z-10 max-w-[90vw] md:max-w-[600px] select-none">
              <h2 className="text-white text-3xl md:text-4xl lg:text-5xl font-bold mb-2 md:mb-4">
                Total Views
              </h2>
              <p className="text-white text-5xl md:text-6xl lg:text-7xl font-bold">
                {error ? (
                  <span className="text-red-500 text-3xl">{error}</span>
                ) : viewCount === null ? (
                  <span className="text-gray-500">Loading...</span>
                ) : (
                  viewCount.toLocaleString()
                )}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Spotlight;
