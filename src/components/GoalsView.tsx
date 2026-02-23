import { Goal } from '../App';
import { Target } from 'lucide-react';

type GoalsViewProps = {
  goals: Goal[];
  onGoalClick: (id: string) => void;
};

export function GoalsView({ goals, onGoalClick }: GoalsViewProps) {
  return (
    <div className="p-6 pb-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-gray-900 mb-1">Goals</h1>
        <p className="text-sm text-gray-500">{goals.length} ongoing journeys</p>
      </div>

      {/* Goals List */}
      {goals.length > 0 ? (
        <div className="space-y-3">
          {goals.map(goal => {
            const recentEntry = goal.entries[goal.entries.length - 1];
            const daysSinceActivity = recentEntry 
              ? Math.floor((new Date().getTime() - recentEntry.date.getTime()) / (1000 * 60 * 60 * 24))
              : null;

            return (
              <button
                key={goal.id}
                onClick={() => onGoalClick(goal.id)}
                className="w-full glass-strong shadow-apple rounded-2xl p-6 text-left hover:scale-[1.02] active:scale-[0.98] transition-all group"
              >
                <div className="flex items-center gap-3 mb-3">
                  <div
                    className="w-5 h-5 rounded-full shadow-sm"
                    style={{ backgroundColor: goal.color }}
                  />
                  <h3 className="text-gray-900 flex-1">{goal.name}</h3>
                  <div className="text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity">
                    →
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <p className="text-sm text-gray-500">
                    {recentEntry 
                      ? daysSinceActivity === 0 
                        ? 'Updated today' 
                        : daysSinceActivity === 1 
                        ? 'Updated yesterday' 
                        : `Updated ${daysSinceActivity} days ago`
                      : 'No activity yet'}
                  </p>
                  <p className="text-xs text-gray-400">
                    {goal.entries.length} {goal.entries.length === 1 ? 'entry' : 'entries'}
                  </p>
                </div>
              </button>
            );
          })}
        </div>
      ) : (
        <div className="glass rounded-2xl p-16 text-center border border-gray-200/50">
          <div className="w-20 h-20 glass-strong rounded-2xl flex items-center justify-center mx-auto mb-4">
            <Target size={40} className="text-gray-400" strokeWidth={2} />
          </div>
          <h3 className="text-gray-900 mb-2">No goals yet</h3>
          <p className="text-sm text-gray-500 max-w-xs mx-auto">
            Start a new journey by adding your first goal
          </p>
        </div>
      )}
    </div>
  );
}
