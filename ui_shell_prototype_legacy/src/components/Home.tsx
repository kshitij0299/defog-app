import { Task, Goal } from '../App';
import { Calendar, Settings, Sun } from 'lucide-react';

type HomeProps = {
  tasks: Task[];
  goals: Goal[];
  onToggle: (id: string) => void;
  onGoalClick: (id: string) => void;
  onNavigateToSettings: () => void;
  onNavigateToDailySummary: () => void;
};

export function Home({ tasks, goals, onToggle, onGoalClick, onNavigateToSettings, onNavigateToDailySummary }: HomeProps) {
  const activeTasks = tasks.filter(t => !t.completed);
  const today = new Date().toLocaleDateString('en-US', { 
    weekday: 'long', 
    month: 'long', 
    day: 'numeric' 
  });

  // Get goals with recent activity
  const activeGoals = goals.slice(0, 3);

  return (
    <div className="p-6 pb-8">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-2">
          <h1 className="text-gray-900">defog</h1>
          <div className="flex items-center gap-2">
            <button 
              onClick={onNavigateToDailySummary}
              className="p-2.5 hover:bg-black/5 rounded-xl transition-all active:scale-95"
            >
              <Sun size={22} className="text-gray-600" strokeWidth={2.5} />
            </button>
            <button 
              onClick={onNavigateToSettings}
              className="p-2.5 hover:bg-black/5 rounded-xl transition-all active:scale-95"
            >
              <Settings size={22} className="text-gray-600" strokeWidth={2.5} />
            </button>
          </div>
        </div>
        <div className="flex items-center gap-2 text-gray-500">
          <Calendar size={16} strokeWidth={2.5} />
          <p className="text-sm">{today}</p>
        </div>
      </div>

      {/* Quick Tasks */}
      <div className="mb-8">
        <h3 className="text-gray-900 mb-4">Today's Tasks</h3>
        {activeTasks.length > 0 ? (
          <div className="space-y-2">
            {activeTasks.slice(0, 3).map(task => (
              <div
                key={task.id}
                className="glass-strong shadow-apple rounded-2xl p-4 flex items-center gap-3 active:scale-[0.98] transition-transform"
              >
                <input
                  type="checkbox"
                  checked={task.completed}
                  onChange={() => onToggle(task.id)}
                  className="w-6 h-6 rounded-lg border-2 border-gray-300 checked:bg-blue-500 checked:border-blue-500 transition-all cursor-pointer"
                />
                <span className="flex-1 text-gray-800">{task.text}</span>
              </div>
            ))}
            {activeTasks.length > 3 && (
              <p className="text-sm text-gray-500 pl-4 pt-2">
                +{activeTasks.length - 3} more tasks
              </p>
            )}
          </div>
        ) : (
          <div className="glass rounded-2xl p-8 text-center border border-gray-200/50">
            <p className="text-gray-400">No tasks for today</p>
            <p className="text-xs text-gray-400 mt-1">You're all caught up ✨</p>
          </div>
        )}
      </div>

      {/* Active Goals */}
      <div>
        <h3 className="text-gray-900 mb-4">Active Goals</h3>
        {activeGoals.length > 0 ? (
          <div className="space-y-3">
            {activeGoals.map(goal => {
              const recentEntry = goal.entries[goal.entries.length - 1];
              const daysSinceActivity = recentEntry 
                ? Math.floor((new Date().getTime() - recentEntry.date.getTime()) / (1000 * 60 * 60 * 24))
                : null;

              return (
                <button
                  key={goal.id}
                  onClick={() => onGoalClick(goal.id)}
                  className="w-full glass-strong shadow-apple rounded-2xl p-5 text-left hover:scale-[1.02] active:scale-[0.98] transition-all"
                >
                  <div className="flex items-center gap-3 mb-2">
                    <div
                      className="w-4 h-4 rounded-full shadow-sm"
                      style={{ backgroundColor: goal.color }}
                    />
                    <h4 className="text-gray-900">{goal.name}</h4>
                  </div>
                  <p className="text-sm text-gray-500">
                    {recentEntry 
                      ? daysSinceActivity === 0 
                        ? 'Updated today' 
                        : daysSinceActivity === 1 
                        ? 'Updated yesterday' 
                        : `Updated ${daysSinceActivity} days ago`
                      : 'No activity yet'}
                  </p>
                </button>
              );
            })}
          </div>
        ) : (
          <div className="glass rounded-2xl p-8 text-center border border-gray-200/50">
            <p className="text-gray-400">No active goals</p>
            <p className="text-xs text-gray-400 mt-1">Start a new journey</p>
          </div>
        )}
      </div>
    </div>
  );
}
