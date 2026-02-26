import { ArrowLeft, TrendingUp, CheckCircle, Target } from 'lucide-react';
import { Task, Goal } from '../App';

type InsightsScreenProps = {
  tasks: Task[];
  goals: Goal[];
  onBack: () => void;
};

export function InsightsScreen({ tasks, goals, onBack }: InsightsScreenProps) {
  const completedTasks = tasks.filter(t => t.completed);
  const activeTasks = tasks.filter(t => !t.completed);
  
  // Calculate streak and stats
  const totalGoalEntries = goals.reduce((sum, goal) => sum + goal.entries.length, 0);
  const goalsWithRecentActivity = goals.filter(goal => {
    const lastEntry = goal.entries[goal.entries.length - 1];
    if (!lastEntry) return false;
    const daysSince = Math.floor((new Date().getTime() - lastEntry.date.getTime()) / (1000 * 60 * 60 * 24));
    return daysSince <= 7;
  });

  // This week's activity
  const thisWeekEntries = goals.reduce((sum, goal) => {
    const weekEntries = goal.entries.filter(entry => {
      const daysSince = Math.floor((new Date().getTime() - entry.date.getTime()) / (1000 * 60 * 60 * 24));
      return daysSince <= 7;
    });
    return sum + weekEntries.length;
  }, 0);

  const thisWeekCompleted = tasks.filter(task => {
    if (!task.completedAt) return false;
    const daysSince = Math.floor((new Date().getTime() - task.completedAt.getTime()) / (1000 * 60 * 60 * 24));
    return daysSince <= 7;
  }).length;

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <button onClick={onBack} className="mb-4 text-gray-600">
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-gray-900 mb-1">Insights</h1>
        <p className="text-sm text-gray-500">Your progress at a glance</p>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-6 space-y-6">
        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="p-4 bg-white border border-gray-200 rounded-lg">
            <div className="flex items-center gap-2 mb-2">
              <CheckCircle size={16} className="text-gray-500" />
              <span className="text-xs text-gray-500">Completed</span>
            </div>
            <p className="text-2xl text-gray-900">{completedTasks.length}</p>
            <p className="text-xs text-gray-500 mt-1">tasks done</p>
          </div>

          <div className="p-4 bg-white border border-gray-200 rounded-lg">
            <div className="flex items-center gap-2 mb-2">
              <CheckCircle size={16} className="text-gray-500" />
              <span className="text-xs text-gray-500">Active</span>
            </div>
            <p className="text-2xl text-gray-900">{activeTasks.length}</p>
            <p className="text-xs text-gray-500 mt-1">tasks pending</p>
          </div>

          <div className="p-4 bg-white border border-gray-200 rounded-lg">
            <div className="flex items-center gap-2 mb-2">
              <Target size={16} className="text-gray-500" />
              <span className="text-xs text-gray-500">Goals</span>
            </div>
            <p className="text-2xl text-gray-900">{goals.length}</p>
            <p className="text-xs text-gray-500 mt-1">ongoing pursuits</p>
          </div>

          <div className="p-4 bg-white border border-gray-200 rounded-lg">
            <div className="flex items-center gap-2 mb-2">
              <TrendingUp size={16} className="text-gray-500" />
              <span className="text-xs text-gray-500">Entries</span>
            </div>
            <p className="text-2xl text-gray-900">{totalGoalEntries}</p>
            <p className="text-xs text-gray-500 mt-1">logged</p>
          </div>
        </div>

        {/* This Week */}
        <div className="p-4 bg-gray-900 text-white rounded-lg">
          <h3 className="mb-4">This Week</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm opacity-90">Tasks completed</span>
              <span className="text-xl">{thisWeekCompleted}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm opacity-90">Goal updates</span>
              <span className="text-xl">{thisWeekEntries}</span>
            </div>
          </div>
        </div>

        {/* Goal Activity */}
        <div>
          <h3 className="text-gray-900 mb-3">Active Goals</h3>
          {goalsWithRecentActivity.length > 0 ? (
            <div className="space-y-2">
              {goalsWithRecentActivity.map(goal => (
                <div key={goal.id} className="p-4 bg-white border border-gray-200 rounded-lg">
                  <div className="flex items-center gap-3 mb-2">
                    <div
                      className="w-3 h-3 rounded-full"
                      style={{ backgroundColor: goal.color }}
                    />
                    <h4 className="text-gray-900">{goal.name}</h4>
                  </div>
                  <p className="text-sm text-gray-500">
                    {goal.entries.length} total entries
                  </p>
                </div>
              ))}
            </div>
          ) : (
            <div className="p-6 border-2 border-dashed border-gray-300 rounded-lg text-center">
              <p className="text-gray-400">No recent goal activity</p>
            </div>
          )}
        </div>

        {/* Encouragement */}
        <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
          <p className="text-sm text-green-800">
            {completedTasks.length > 0 
              ? `You've completed ${completedTasks.length} task${completedTasks.length === 1 ? '' : 's'}. Keep the momentum going!`
              : 'Start adding tasks and tracking your goals to see insights here.'}
          </p>
        </div>
      </div>
    </div>
  );
}
