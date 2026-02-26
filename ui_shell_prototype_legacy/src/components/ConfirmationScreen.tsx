import { useState } from 'react';
import { ArrowLeft, CheckCircle, Target, X, Check } from 'lucide-react';

type ConfirmationScreenProps = {
  detectedTasks: string[];
  detectedGoals: string[];
  onConfirm: (confirmedTasks: string[], confirmedGoals: string[]) => void;
  onBack: () => void;
};

export function ConfirmationScreen({ 
  detectedTasks, 
  detectedGoals, 
  onConfirm, 
  onBack 
}: ConfirmationScreenProps) {
  const [tasks, setTasks] = useState<string[]>(detectedTasks);
  const [goals, setGoals] = useState<string[]>(detectedGoals);

  const removeTask = (index: number) => {
    setTasks(tasks.filter((_, i) => i !== index));
  };

  const removeGoal = (index: number) => {
    setGoals(goals.filter((_, i) => i !== index));
  };

  const handleConfirm = () => {
    onConfirm(tasks, goals);
  };

  const hasItems = tasks.length > 0 || goals.length > 0;

  return (
    <div className="flex flex-col h-full p-6">
      {/* Header */}
      <div className="mb-8">
        <button 
          onClick={onBack} 
          className="mb-4 p-2 -ml-2 hover:bg-black/5 rounded-xl transition-all active:scale-95"
        >
          <ArrowLeft size={24} className="text-gray-600" strokeWidth={2.5} />
        </button>
        <h1 className="text-gray-900 mb-2">Review & Confirm</h1>
        <p className="text-sm text-gray-500">
          I've categorized your thoughts. Tap to remove anything that doesn't look right.
        </p>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto space-y-6">
        {/* Tasks Section */}
        {tasks.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-4">
              <CheckCircle size={20} className="text-blue-600" strokeWidth={2.5} />
              <h3 className="text-gray-900">Are these your tasks?</h3>
            </div>
            <div className="space-y-2">
              {tasks.map((task, index) => (
                <div
                  key={index}
                  className="glass-strong shadow-apple rounded-2xl p-4 flex items-center gap-3 group"
                >
                  <Check size={18} className="text-green-600" strokeWidth={2.5} />
                  <span className="flex-1 text-gray-800">{task}</span>
                  <button
                    onClick={() => removeTask(index)}
                    className="p-2 hover:bg-red-50 rounded-xl opacity-0 group-hover:opacity-100 transition-all active:scale-95"
                  >
                    <X size={18} className="text-red-600" strokeWidth={2.5} />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Goals Section */}
        {goals.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-4">
              <Target size={20} className="text-purple-600" strokeWidth={2.5} />
              <h3 className="text-gray-900">Are these your goals?</h3>
            </div>
            <div className="space-y-2">
              {goals.map((goal, index) => (
                <div
                  key={index}
                  className="glass-strong shadow-apple rounded-2xl p-4 flex items-center gap-3 group"
                >
                  <Check size={18} className="text-green-600" strokeWidth={2.5} />
                  <span className="flex-1 text-gray-800">{goal}</span>
                  <button
                    onClick={() => removeGoal(index)}
                    className="p-2 hover:bg-red-50 rounded-xl opacity-0 group-hover:opacity-100 transition-all active:scale-95"
                  >
                    <X size={18} className="text-red-600" strokeWidth={2.5} />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Empty State */}
        {!hasItems && (
          <div className="glass rounded-2xl p-12 text-center border border-gray-200/50">
            <p className="text-gray-400">All items removed</p>
            <p className="text-xs text-gray-400 mt-2">Go back to add more</p>
          </div>
        )}
      </div>

      {/* Bottom Actions */}
      <div className="flex gap-3 mt-6">
        <button
          onClick={onBack}
          className="px-6 py-4 glass-strong rounded-2xl hover:bg-white/80 active:scale-95 transition-all text-gray-700"
        >
          Back
        </button>
        <button
          onClick={handleConfirm}
          disabled={!hasItems}
          className="flex-1 py-4 bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-2xl disabled:opacity-30 hover:from-blue-600 hover:to-blue-700 active:scale-[0.98] transition-all shadow-apple-lg"
        >
          Looks Good!
        </button>
      </div>
    </div>
  );
}
