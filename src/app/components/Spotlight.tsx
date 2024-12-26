"use client";

import React, { useEffect, useRef } from "react";

const Spotlight: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

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

      container.style.setProperty("--mouse-x", `${x}%`);
      container.style.setProperty("--mouse-y", `${y}%`);
    };

    container.addEventListener("mousemove", handleInteraction);
    container.addEventListener("touchmove", handleInteraction, {
      passive: false,
    });

    return () => {
      container.removeEventListener("mousemove", handleInteraction);
      container.removeEventListener("touchmove", handleInteraction);
    };
  }, []);

  return (
    <div
      ref={containerRef}
      className="relative min-h-screen w-full bg-black overflow-hidden"
    >
      {/* Spotlight effect */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_var(--mouse-x,50%)_var(--mouse-y,50%),rgba(255,255,255,0.15)_0%,transparent_50%)] md:bg-[radial-gradient(circle_at_var(--mouse-x,50%)_var(--mouse-y,50%),rgba(255,255,255,0.15)_0%,transparent_25%)] transition-transform duration-100"></div>

      {/* Content container */}
      <div className="absolute inset-0 flex items-center justify-center p-4 md:p-8">
        {/* Glass card */}
        <div className="relative group">
          {/* Animated border gradient */}
          <div className="absolute -inset-0.5 bg-gradient-to-b from-black to-purple-500 rounded-lg blur opacity-30 group-hover:opacity-50 transition duration-1000"></div>
          {/* Glass card content */}
          <div className="relative px-7 py-6 md:px-10 md:py-8 bg-black/50 backdrop-blur-xl rounded-lg border border-white/10">
            <div className="text-center z-10 max-w-[90vw] md:max-w-[600px] select-none">
              <h2 className="text-white text-3xl md:text-4xl lg:text-5xl font-bold mb-2 md:mb-4">
                Total Views
              </h2>
              <p className="text-white text-5xl md:text-6xl lg:text-7xl font-bold">
                1,234
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Spotlight;
