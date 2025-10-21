import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';
import { MessageSquare, Send, Search, Loader, Wifi, WifiOff, Check, CheckCheck, Circle } from 'lucide-react';
import { Card, CardContent } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '../components/ui/avatar';
import { ScrollArea } from '../components/ui/scroll-area';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '../components/ui/dialog';
import { Badge } from '../components/ui/badge';
import { toast } from 'sonner';
import { Navigation } from '../components/Navigation';

const API_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8001';

export default function Messages() {
  const { user } = useAuth();
  const [conversations, setConversations] = useState([]);
  const [selectedConv, setSelectedConv] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [typingUsers, setTypingUsers] = useState([]);
  const [showNewChat, setShowNewChat] = useState(false);
  const [searchInput, setSearchInput] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [isConnected, setIsConnected] = useState(true);
  const [loading, setLoading] = useState(false);
  
  const messagesEndRef = useRef(null);
  const typingTimeoutRef = useRef(null);

  useEffect(() => {
    if (user) {
      fetchConversations();
      updatePresence('online');
    }
    return () => {
      if (user) {
        updatePresence('offline');
      }
    };
  }, [user]);

  useEffect(() => {
    if (selectedConv) {
      fetchMessages(selectedConv.id);
      const interval = setInterval(() => {
        fetchMessages(selectedConv.id);
      }, 2000);
      return () => clearInterval(interval);
    }
  }, [selectedConv]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    const checkConnection = setInterval(() => {
      setIsConnected(navigator.onLine);
    }, 5000);
    return () => clearInterval(checkConnection);
  }, []);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const updatePresence = async (status) => {
    try {
      await axios.post(`${API_URL}/api/presence`, { status }, { withCredentials: true });
    } catch (error) {
      console.error('Presence update error:', error);
    }
  };

  const fetchConversations = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/conversations`, { withCredentials: true });
      setConversations(response.data.conversations || []);
    } catch (error) {
      console.error('Failed to load conversations:', error);
      toast.error('Failed to load conversations');
    }
  };

  const fetchMessages = async (conversationId) => {
    try {
      const response = await axios.get(`${API_URL}/api/conversations/${conversationId}/messages`, { withCredentials: true });
      setMessages(response.data.messages || []);
    } catch (error) {
      console.error('Failed to fetch messages:', error);
    }
  };

  const searchUsers = async (query) => {
    if (!query.trim()) {
      setSearchResults([]);
      return;
    }
    setIsSearching(true);
    try {
      const response = await axios.get(`${API_URL}/api/users/search?q=${encodeURIComponent(query)}`, { withCredentials: true });
      setSearchResults(response.data.users || []);
    } catch (error) {
      console.error('Search error:', error);
      toast.error('Failed to search users');
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const sendMessage = async (e) => {
    e.preventDefault();
    if (!newMessage.trim() || !selectedConv) return;
    
    try {
      const response = await axios.post(
        `${API_URL}/api/messages`,
        {
          conversation_id: selectedConv.id,
          content: newMessage,
          message_type: 'text'
        },
        { withCredentials: true }
      );
      setMessages([...messages, response.data.message]);
      setNewMessage('');
      scrollToBottom();
      toast.success('Message sent');
    } catch (error) {
      console.error('Send message error:', error);
      toast.error('Failed to send message');
    }
  };

  const createNewConversation = async (e) => {
    e.preventDefault();
    if (!selectedUser) {
      toast.error('Please select a user');
      return;
    }
    
    setLoading(true);
    try {
      const response = await axios.post(
        `${API_URL}/api/conversations`,
        {
          participant_ids: [selectedUser.id],
          type: 'direct'
        },
        { withCredentials: true }
      );
      setConversations([response.data.conversation, ...conversations]);
      setSelectedConv(response.data.conversation);
      setShowNewChat(false);
      setSearchInput('');
      setSelectedUser(null);
      setSearchResults([]);
      toast.success('Conversation created!');
    } catch (error) {
      console.error('Conversation creation error:', error);
      toast.error(error.response?.data?.detail || 'Failed to create conversation');
    } finally {
      setLoading(false);
    }
  };

  const formatTime = (timestamp) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    if (diff < 60000) return 'Just now';
    if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}h ago`;
    return date.toLocaleDateString();
  };

  if (!user) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Card className="p-8">
          <p className="text-lg">Please log in to access messages</p>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50/50 via-blue-50/30 to-indigo-50/50 dark:from-slate-900 dark:via-purple-950/30 dark:to-slate-900">
      <Navigation />
      
      <AnimatePresence>
        {!isConnected && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="max-w-7xl mx-auto mb-4 mt-20 px-4"
          >
            <div className="bg-destructive text-destructive-foreground px-4 py-2 rounded-lg flex items-center justify-center gap-2">
              <WifiOff className="h-4 w-4" />
              <span className="text-sm font-medium">No connection - Messages may not sync</span>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="bg-card dark:bg-card/50 dark:backdrop-blur-xl rounded-lg shadow-xl overflow-hidden" style={{ height: 'calc(100vh - 200px)' }}>
          <div className="flex h-full">
            {/* Conversations List */}
            <div className="w-1/3 border-r border-border flex flex-col">
              <div className="p-4 border-b border-border">
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center gap-2">
                    <h2 className="text-2xl font-bold heading-font">Messages</h2>
                    {isConnected && (
                      <Badge variant="secondary" className="flex items-center gap-1">
                        <Wifi className="h-3 w-3" />
                        Live
                      </Badge>
                    )}
                  </div>
                  <Dialog open={showNewChat} onOpenChange={setShowNewChat}>
                    <DialogTrigger asChild>
                      <Button size="sm">
                        <MessageSquare className="w-4 h-4 mr-2" />
                        New
                      </Button>
                    </DialogTrigger>
                    <DialogContent>
                      <DialogHeader>
                        <DialogTitle>New Conversation</DialogTitle>
                      </DialogHeader>
                      <form onSubmit={createNewConversation} className="space-y-4">
                        <div className="space-y-2">
                          <Input
                            placeholder="Search by name or email"
                            value={searchInput}
                            onChange={(e) => {
                              setSearchInput(e.target.value);
                              searchUsers(e.target.value);
                            }}
                          />
                          {isSearching && (
                            <div className="flex items-center justify-center py-2">
                              <Loader className="h-4 w-4 animate-spin" />
                            </div>
                          )}
                          {searchResults.length > 0 && (
                            <div className="border rounded-lg max-h-48 overflow-y-auto">
                              {searchResults.map(u => (
                                <div
                                  key={u.id}
                                  onClick={() => {
                                    setSelectedUser(u);
                                    setSearchInput(u.name || u.email);
                                    setSearchResults([]);
                                  }}
                                  className={`p-3 cursor-pointer hover:bg-muted transition-colors ${
                                    selectedUser?.id === u.id ? 'bg-primary/10' : ''
                                  }`}
                                >
                                  <div className="flex items-center gap-2">
                                    <Avatar className="h-8 w-8">
                                      <AvatarImage src={u.avatar} />
                                      <AvatarFallback>{u.name?.[0] || 'U'}</AvatarFallback>
                                    </Avatar>
                                    <div>
                                      <p className="font-medium text-sm">{u.name}</p>
                                      <p className="text-xs text-muted-foreground">{u.email}</p>
                                    </div>
                                  </div>
                                </div>
                              ))}
                            </div>
                          )}
                          {searchInput && searchResults.length === 0 && !isSearching && (
                            <p className="text-xs text-muted-foreground">No users found</p>
                          )}
                        </div>
                        <Button type="submit" className="w-full" disabled={!selectedUser || loading}>
                          {loading ? <Loader className="h-4 w-4 animate-spin mr-2" /> : null}
                          Start Conversation
                        </Button>
                      </form>
                    </DialogContent>
                  </Dialog>
                </div>
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                  <Input
                    placeholder="Search conversations..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>

              <ScrollArea className="flex-1">
                <div className="space-y-2 p-4">
                  {conversations.length === 0 ? (
                    <div className="text-center py-8 text-muted-foreground">
                      <MessageSquare className="h-8 w-8 mx-auto mb-2 opacity-50" />
                      <p>No conversations yet</p>
                    </div>
                  ) : (
                    conversations.map(conv => (
                      <motion.div
                        key={conv.id}
                        whileHover={{ scale: 1.02 }}
                        onClick={() => setSelectedConv(conv)}
                        className={`p-3 rounded-lg cursor-pointer transition-all ${
                          selectedConv?.id === conv.id
                            ? 'bg-primary/20 border-primary/50'
                            : 'hover:bg-muted'
                        }`}
                      >
                        <div className="flex items-center gap-3">
                          <Avatar>
                            <AvatarImage src={conv.participant_avatar} />
                            <AvatarFallback>{conv.participant_name?.[0]}</AvatarFallback>
                          </Avatar>
                          <div className="flex-1 min-w-0">
                            <p className="font-semibold text-sm truncate">{conv.participant_name}</p>
                            <p className="text-xs text-muted-foreground truncate">{conv.last_message || 'No messages'}</p>
                          </div>
                        </div>
                      </motion.div>
                    ))
                  )}
                </div>
              </ScrollArea>
            </div>

            {/* Messages Area */}
            <div className="flex-1 flex flex-col">
              {selectedConv ? (
                <>
                  <div className="p-4 border-b border-border flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <Avatar>
                        <AvatarImage src={selectedConv.participant_avatar} />
                        <AvatarFallback>{selectedConv.participant_name?.[0]}</AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="font-semibold">{selectedConv.participant_name}</p>
                        <p className="text-xs text-muted-foreground">Active now</p>
                      </div>
                    </div>
                  </div>

                  <ScrollArea className="flex-1 p-4">
                    <div className="space-y-4">
                      {messages.length === 0 ? (
                        <div className="text-center py-8 text-muted-foreground">
                          <MessageSquare className="h-8 w-8 mx-auto mb-2 opacity-50" />
                          <p>No messages yet. Start the conversation!</p>
                        </div>
                      ) : (
                        messages.map((msg, idx) => (
                          <motion.div
                            key={msg.id || idx}
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            className={`flex ${msg.sender_id === user.id ? 'justify-end' : 'justify-start'}`}
                          >
                            <div
                              className={`max-w-xs px-4 py-2 rounded-lg ${
                                msg.sender_id === user.id
                                  ? 'bg-primary text-primary-foreground'
                                  : 'bg-muted'
                              }`}
                            >
                              <p className="text-sm">{msg.content}</p>
                              <p className="text-xs opacity-70 mt-1">{formatTime(msg.created_at)}</p>
                            </div>
                          </motion.div>
                        ))
                      )}
                      <div ref={messagesEndRef} />
                    </div>
                  </ScrollArea>

                  <form onSubmit={sendMessage} className="p-4 border-t border-border">
                    <div className="flex gap-2">
                      <Input
                        placeholder="Type a message..."
                        value={newMessage}
                        onChange={(e) => setNewMessage(e.target.value)}
                      />
                      <Button type="submit" size="icon">
                        <Send className="h-4 w-4" />
                      </Button>
                    </div>
                  </form>
                </>
              ) : (
                <div className="flex items-center justify-center h-full text-muted-foreground">
                  <div className="text-center">
                    <MessageSquare className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>Select a conversation to start messaging</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
