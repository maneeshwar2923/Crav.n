import React, { useState } from 'react';
import { AppBar } from '../AppBar';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { Send } from 'lucide-react';

export function ChatScreen({ onBack }: { onBack: () => void }) {
  const [message, setMessage] = useState('');
  
  const messages = [
    {
      id: '1',
      sender: 'host',
      text: 'Hi! Thanks for your interest in the biryani!',
      time: '10:30 AM'
    },
    {
      id: '2',
      sender: 'user',
      text: 'Hello! Is it still available for pickup today?',
      time: '10:32 AM'
    },
    {
      id: '3',
      sender: 'host',
      text: 'Yes, absolutely! You can pick it up between 6-8 PM.',
      time: '10:33 AM'
    },
    {
      id: '4',
      sender: 'user',
      text: 'Perfect! I\'ll come around 7 PM. Is the spice level medium?',
      time: '10:35 AM'
    },
    {
      id: '5',
      sender: 'host',
      text: 'Yes, it\'s medium spiced. Not too hot. See you at 7!',
      time: '10:36 AM'
    }
  ];
  
  const handleSend = () => {
    if (message.trim()) {
      console.log('Sending:', message);
      setMessage('');
    }
  };
  
  return (
    <div className="h-screen flex flex-col bg-[#F5F5F5]">
      {/* Chat Header */}
      <div className="bg-[#006D3B] shadow-lg">
        <div className="px-4 py-3 flex items-center gap-3">
          <button onClick={onBack} className="text-white">
            ←
          </button>
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop"
            alt="Priya"
            className="w-10 h-10 rounded-full object-cover border-2 border-white"
          />
          <div className="flex-1">
            <h3 className="text-white">Priya Sharma</h3>
            <p className="text-white/80 text-xs">Online</p>
          </div>
        </div>
      </div>
      
      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-6 space-y-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex ${msg.sender === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[75%] rounded-2xl px-4 py-3 ${
                msg.sender === 'user'
                  ? 'bg-[#006D3B] text-white rounded-br-sm'
                  : 'bg-white text-[#1A1A1A] rounded-bl-sm'
              }`}
            >
              <p className="mb-1">{msg.text}</p>
              <p
                className={`text-xs ${
                  msg.sender === 'user' ? 'text-white/70' : 'text-[#999999]'
                }`}
              >
                {msg.time}
              </p>
            </div>
          </div>
        ))}
      </div>
      
      {/* Input */}
      <div className="bg-white border-t border-[#E0E0E0] px-4 py-3">
        <div className="flex items-center gap-2">
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
            placeholder="Type a message..."
            className="flex-1 px-4 py-3 border border-[#E0E0E0] rounded-full focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20"
          />
          <button
            onClick={handleSend}
            className="w-12 h-12 bg-[#006D3B] rounded-full flex items-center justify-center text-white hover:bg-[#008C4D] transition-colors disabled:opacity-50"
            disabled={!message.trim()}
          >
            <Send size={20} />
          </button>
        </div>
      </div>
    </div>
  );
}
