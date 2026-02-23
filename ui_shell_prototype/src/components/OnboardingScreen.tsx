import { useState } from 'react';
import { ChevronRight, Brain, CheckCircle, Target } from 'lucide-react';

type OnboardingScreenProps = {
  onComplete: () => void;
};

export function OnboardingScreen({ onComplete }: OnboardingScreenProps) {
  const [step, setStep] = useState(0);

  const steps = [
    {
      icon: <Brain size={56} className="text-gray-900" strokeWidth={2} />,
      title: 'Clear your mind',
      description: 'Dump everything on your mind. Tasks, goals, ideas—all of it. We\'ll help you make sense of the chaos.',
    },
    {
      icon: <CheckCircle size={56} className="text-gray-900" strokeWidth={2} />,
      title: 'Tasks are finite',
      description: 'One-off things you need to do. Check them off and move on. No overthinking.',
    },
    {
      icon: <Target size={56} className="text-gray-900" strokeWidth={2} />,
      title: 'Goals are journeys',
      description: 'Ongoing pursuits that need your attention. Track your progress day by day, without pressure.',
    },
  ];

  const currentStep = steps[step];

  return (
    <div className="flex flex-col h-full p-6 bg-gradient-to-br from-blue-50/30 via-purple-50/20 to-pink-50/30">
      {/* Logo */}
      <div className="py-8">
        <h1 className="text-gray-900">defog</h1>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center text-center px-4">
        <div className="glass-strong shadow-apple-lg rounded-3xl w-28 h-28 flex items-center justify-center mb-8">
          {currentStep.icon}
        </div>

        <h2 className="text-gray-900 mb-4 px-4">{currentStep.title}</h2>
        <p className="text-gray-600 max-w-sm leading-relaxed">{currentStep.description}</p>
      </div>

      {/* Progress dots */}
      <div className="flex justify-center gap-2 mb-8">
        {steps.map((_, i) => (
          <div
            key={i}
            className={`h-2 rounded-full transition-all ${
              i === step 
                ? 'w-8 bg-gray-900' 
                : 'w-2 bg-gray-300'
            }`}
          />
        ))}
      </div>

      {/* Navigation */}
      <div className="flex gap-3">
        {step < steps.length - 1 ? (
          <>
            <button
              onClick={onComplete}
              className="px-6 py-4 text-gray-500 hover:text-gray-700 transition-colors active:scale-95"
            >
              Skip
            </button>
            <button
              onClick={() => setStep(step + 1)}
              className="flex-1 py-4 bg-gradient-to-br from-gray-900 to-gray-800 text-white rounded-2xl flex items-center justify-center gap-2 shadow-apple-lg hover:from-gray-800 hover:to-gray-700 active:scale-[0.98] transition-all"
            >
              Next
              <ChevronRight size={20} strokeWidth={2.5} />
            </button>
          </>
        ) : (
          <button
            onClick={onComplete}
            className="flex-1 py-4 bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-2xl shadow-apple-lg hover:from-blue-600 hover:to-blue-700 active:scale-[0.98] transition-all"
          >
            Get Started
          </button>
        )}
      </div>
    </div>
  );
}
