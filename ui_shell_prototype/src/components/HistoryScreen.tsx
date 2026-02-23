import { ArrowLeft, CheckCircle } from 'lucide-react';
import { Task } from '../App';

type HistoryScreenProps = {
  tasks: Task[];
  onBack: () => void;
};

export function HistoryScreen({ tasks, onBack }: HistoryScreenProps) {
  const completedTasks = tasks
    .filter(t => t.completed)
    .sort((a, b) => {
      const dateA = a.completedAt || a.createdAt;
      const dateB = b.completedAt || b.createdAt;
      return dateB.getTime() - dateA.getTime();
    });

  const groupedByDate = completedTasks.reduce((groups, task) => {
    const date = (task.completedAt || task.createdAt).toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric'
    });
    if (!groups[date]) {
      groups[date] = [];
    }
    groups[date].push(task);
    return groups;
  }, {} as Record<string, Task[]>);

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <button onClick={onBack} className="mb-4 text-gray-600">
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-gray-900 mb-1">History</h1>
        <p className="text-sm text-gray-500">{completedTasks.length} completed tasks</p>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-6">
        {completedTasks.length > 0 ? (
          <div className="space-y-6">
            {Object.entries(groupedByDate).map(([date, tasks]) => (
              <div key={date}>
                <h3 className="text-sm text-gray-500 mb-3">{date}</h3>
                <div className="space-y-2">
                  {tasks.map(task => (
                    <div
                      key={task.id}
                      className="flex items-start gap-3 p-4 bg-white border border-gray-200 rounded-lg"
                    >
                      <CheckCircle size={20} className="text-green-500 flex-shrink-0 mt-0.5" />
                      <span className="flex-1 text-gray-700">{task.text}</span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <CheckCircle size={32} className="text-gray-400" />
            </div>
            <p className="text-gray-400 mb-2">No completed tasks yet</p>
            <p className="text-sm text-gray-400 max-w-xs">
              Start checking off tasks to build your accomplishment history
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
