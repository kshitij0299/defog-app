export function ProcessingScreen() {
  return (
    <div className="h-full flex flex-col items-center justify-center p-6 bg-gradient-to-br from-blue-50/30 via-purple-50/20 to-pink-50/30">
      <div className="mb-8">
        {/* Animated circles with glass effect */}
        <div className="relative w-32 h-32">
          <div className="absolute inset-0 glass-strong rounded-full shadow-apple" />
          <div
            className="absolute inset-0 border-[5px] border-transparent border-t-gray-900 rounded-full animate-spin"
            style={{ animationDuration: "1s" }}
          />
        </div>
      </div>

      <h2 className="text-gray-900 mb-2">Making sense...</h2>
      <p className="text-sm text-gray-500 text-center max-w-xs leading-relaxed">
        Categorizing your thoughts into tasks and goals
      </p>

      {/* Progress dots */}
      <div className="flex gap-2 mt-8">
        {[0, 1, 2].map((i) => (
          <div
            key={i}
            className="w-2.5 h-2.5 bg-gray-900 rounded-full animate-pulse"
            style={{ animationDelay: `${i * 0.2}s` }}
          />
        ))}
      </div>
    </div>
  );
}