import { useState } from 'react';
import { Goal } from '../App';
import { X } from 'lucide-react';

type EditGoalModalProps = {
  goal: Goal;
  onSave: (id: string, name: string, color: string) => void;
  onClose: () => void;
};

const PRESET_COLORS = [
  '#A78BFA', // Purple
  '#34D399', // Green
  '#F87171', // Red
  '#60A5FA', // Blue
  '#FBBF24', // Yellow
  '#F472B6', // Pink
  '#FB923C', // Orange
  '#A3A3A3', // Gray
];

export function EditGoalModal({ goal, onSave, onClose }: EditGoalModalProps) {
  const [name, setName] = useState(goal.name);
  const [color, setColor] = useState(goal.color);

  const handleSave = () => {
    if (name.trim()) {
      onSave(goal.id, name.trim(), color);
    }
  };

  return (
    <div className="absolute inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center z-50 p-6">
      <div className="glass-strong shadow-apple-lg rounded-3xl w-full max-w-sm overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-white/30">
          <h2 className="text-gray-900">Edit Goal</h2>
          <button 
            onClick={onClose} 
            className="p-2 hover:bg-black/5 rounded-xl transition-all active:scale-95"
          >
            <X size={24} className="text-gray-500" strokeWidth={2.5} />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Name Input */}
          <div>
            <label className="block text-sm text-gray-600 mb-2">Goal Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full p-4 glass rounded-2xl border border-gray-200/50 focus:outline-none focus:ring-2 focus:ring-blue-500/50 text-gray-900 placeholder:text-gray-400"
              placeholder="e.g., Motion Design"
            />
          </div>

          {/* Color Picker */}
          <div>
            <label className="block text-sm text-gray-600 mb-3">Color</label>
            <div className="grid grid-cols-4 gap-3">
              {PRESET_COLORS.map((presetColor) => (
                <button
                  key={presetColor}
                  onClick={() => setColor(presetColor)}
                  className={`w-full aspect-square rounded-2xl border-[3px] transition-all active:scale-95 ${
                    color === presetColor 
                      ? 'border-gray-900 scale-105 shadow-apple' 
                      : 'border-transparent hover:scale-105'
                  }`}
                  style={{ backgroundColor: presetColor }}
                />
              ))}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="p-6 border-t border-white/30 flex gap-3">
          <button
            onClick={onClose}
            className="flex-1 py-3.5 glass rounded-2xl hover:bg-white/80 active:scale-95 transition-all text-gray-700"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={!name.trim()}
            className="flex-1 py-3.5 bg-gray-900 text-white rounded-2xl disabled:opacity-40 hover:bg-gray-800 active:scale-95 transition-all shadow-apple"
          >
            Save Changes
          </button>
        </div>
      </div>
    </div>
  );
}
