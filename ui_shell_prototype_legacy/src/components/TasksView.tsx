import { Task } from '../App';
import { useState } from 'react';
import { MoreVertical, Edit2, Trash2, CheckCircle } from 'lucide-react';

type TasksViewProps = {
  tasks: Task[];
  onToggle: (id: string) => void;
  onDelete: (id: string) => void;
  onEdit: (id: string, text: string) => void;
};

export function TasksView({ tasks, onToggle, onDelete, onEdit }: TasksViewProps) {
  const activeTasks = tasks.filter(t => !t.completed);
  const completedTasks = tasks.filter(t => t.completed);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editText, setEditText] = useState('');
  const [menuOpenId, setMenuOpenId] = useState<string | null>(null);

  const startEdit = (task: Task) => {
    setEditingId(task.id);
    setEditText(task.text);
    setMenuOpenId(null);
  };

  const saveEdit = () => {
    if (editingId && editText.trim()) {
      onEdit(editingId, editText.trim());
      setEditingId(null);
      setEditText('');
    }
  };

  return (
    <div className="p-6 pb-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-gray-900 mb-1">Tasks</h1>
        <p className="text-sm text-gray-500">{activeTasks.length} active</p>
      </div>

      {/* Active Tasks */}
      {activeTasks.length > 0 ? (
        <div className="mb-8">
          <div className="space-y-2">
            {activeTasks.map(task => (
              <div key={task.id} className="relative">
                {editingId === task.id ? (
                  <div className="glass-strong shadow-apple rounded-2xl p-4 border-2 border-blue-500">
                    <input
                      type="text"
                      value={editText}
                      onChange={(e) => setEditText(e.target.value)}
                      className="w-full mb-3 p-3 glass rounded-xl border border-gray-200/50 focus:outline-none focus:ring-2 focus:ring-blue-500/50 text-gray-900"
                      autoFocus
                    />
                    <div className="flex gap-2">
                      <button
                        onClick={saveEdit}
                        className="px-5 py-2.5 bg-gray-900 text-white rounded-xl hover:bg-gray-800 active:scale-95 transition-all shadow-apple"
                      >
                        Save
                      </button>
                      <button
                        onClick={() => setEditingId(null)}
                        className="px-5 py-2.5 glass-strong rounded-xl hover:bg-white/80 active:scale-95 transition-all text-gray-700"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <div className="flex items-start gap-3 p-4 glass-strong shadow-apple rounded-2xl group hover:scale-[1.01] active:scale-[0.99] transition-all">
                    <input
                      type="checkbox"
                      checked={task.completed}
                      onChange={() => onToggle(task.id)}
                      className="mt-0.5 w-6 h-6 rounded-lg border-2 border-gray-300 checked:bg-blue-500 checked:border-blue-500 transition-all cursor-pointer"
                    />
                    <span className="flex-1 text-gray-800">{task.text}</span>
                    <button
                      onClick={() => setMenuOpenId(menuOpenId === task.id ? null : task.id)}
                      className="p-1.5 hover:bg-black/5 rounded-lg opacity-0 group-hover:opacity-100 transition-all active:scale-95"
                    >
                      <MoreVertical size={18} className="text-gray-500" strokeWidth={2.5} />
                    </button>

                    {menuOpenId === task.id && (
                      <div className="absolute right-4 top-16 glass-strong shadow-apple-lg rounded-2xl overflow-hidden z-10 min-w-[140px]">
                        <button
                          onClick={() => startEdit(task)}
                          className="w-full flex items-center gap-3 px-4 py-3 hover:bg-black/5 transition-colors text-left"
                        >
                          <Edit2 size={16} className="text-gray-600" strokeWidth={2.5} />
                          <span className="text-sm text-gray-900">Edit</span>
                        </button>
                        <div className="h-px bg-gray-200/50" />
                        <button
                          onClick={() => {
                            onDelete(task.id);
                            setMenuOpenId(null);
                          }}
                          className="w-full flex items-center gap-3 px-4 py-3 hover:bg-red-50 transition-colors text-left"
                        >
                          <Trash2 size={16} className="text-red-600" strokeWidth={2.5} />
                          <span className="text-sm text-red-600">Delete</span>
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div className="glass rounded-2xl p-12 text-center mb-8 border border-gray-200/50">
          <div className="w-16 h-16 glass-strong rounded-2xl flex items-center justify-center mx-auto mb-3">
            <CheckCircle size={32} className="text-gray-400" strokeWidth={2} />
          </div>
          <p className="text-gray-400">No active tasks</p>
          <p className="text-xs text-gray-400 mt-2">You're all caught up ✨</p>
        </div>
      )}

      {/* Completed Tasks */}
      {completedTasks.length > 0 && (
        <div>
          <h3 className="text-gray-500 mb-4">Completed</h3>
          <div className="space-y-2">
            {completedTasks.map(task => (
              <div
                key={task.id}
                className="flex items-start gap-3 p-4 glass rounded-2xl opacity-60"
              >
                <input
                  type="checkbox"
                  checked={task.completed}
                  onChange={() => onToggle(task.id)}
                  className="mt-0.5 w-6 h-6 rounded-lg border-2 border-gray-300 checked:bg-blue-500 checked:border-blue-500 transition-all cursor-pointer"
                />
                <span className="flex-1 text-gray-600 line-through">{task.text}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
