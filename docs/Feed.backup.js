import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import axios from 'axios';
import { API } from '../App';
import { Navigation } from '../components/Navigation';
import { useAuth } from '../contexts/AuthContext';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardHeader } from '../components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '../components/ui/avatar';
import { Textarea } from '../components/ui/textarea';
import { Badge } from '../components/ui/badge';
import { toast } from 'sonner';
import { Heart, MessageCircle, Share2, Send, Calendar, TrendingUp } from 'lucide-react';
import { format } from 'date-fns';

const Feed = () => {
  const { user } = useAuth();
  const [posts, setPosts] = useState([]);
  const [events, setEvents] = useState([]);
  const [newPost, setNewPost] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchPosts();
    fetchEvents();
  }, []);

  const fetchPosts = async () => {
    try {
      const response = await axios.get(`${API}/posts`);
      setPosts(response.data);
    } catch (error) {
      console.error('Error fetching posts:', error);
    }
  };

  const fetchEvents = async () => {
    try {
      const response = await axios.get(`${API}/events?limit=5`);
      setEvents(response.data);
    } catch (error) {
      console.error('Error fetching events:', error);
    }
  };

  const handleCreatePost = async (e) => {
    e.preventDefault();
    if (!newPost.trim()) return;

    setLoading(true);
    try {
      await axios.post(`${API}/posts`, { content: newPost });
      setNewPost('');
      fetchPosts();
      toast.success('Post created!');
    } catch (error) {
      toast.error('Failed to create post');
    } finally {
      setLoading(false);
    }
  };

  const handleLike = async (postId) => {
    try {
      await axios.post(`${API}/posts/${postId}/like`);
      fetchPosts();
    } catch (error) {
      toast.error('Failed to like post');
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Navigation />
      <div className="mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl py-8">
        <div className="lg:grid lg:grid-cols-12 lg:gap-6">
          {/* Main Feed */}
          <div className="lg:col-span-7 space-y-6">
            {/* Create Post */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
            >
              <Card data-testid="create-post-card">
                <CardContent className="pt-6">
                  <form onSubmit={handleCreatePost}>
                    <div className="flex gap-4">
                      <Avatar>
                        <AvatarImage src={user?.avatar} />
                        <AvatarFallback>{user?.name?.[0]}</AvatarFallback>
                      </Avatar>
                      <div className="flex-1">
                        <Textarea
                          placeholder="Share your impact story..."
                          value={newPost}
                          onChange={(e) => setNewPost(e.target.value)}
                          className="min-h-[100px] resize-none"
                          data-testid="post-textarea"
                        />
                        <div className="flex justify-end mt-4">
                          <Button type="submit" disabled={loading || !newPost.trim()} data-testid="create-post-button">
                            <Send className="h-4 w-4 mr-2" />
                            Post
                          </Button>
                        </div>
                      </div>
                    </div>
                  </form>
                </CardContent>
              </Card>
            </motion.div>

            {/* Posts Feed */}
            <div className="space-y-4">
              {posts.map((post, index) => (
                <motion.div
                  key={post.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3, delay: index * 0.05 }}
                >
                  <Card data-testid="feed-post-card">
                    <CardHeader>
                      <div className="flex items-start gap-4">
                        <Avatar>
                          <AvatarImage src={post.author_avatar} />
                          <AvatarFallback>{post.author_name?.[0]}</AvatarFallback>
                        </Avatar>
                        <div className="flex-1">
                          <div className="flex items-center justify-between">
                            <div>
                              <p className="heading-font font-semibold text-sm">{post.author_name}</p>
                              <p className="text-xs text-muted-foreground">
                                {format(new Date(post.created_at), 'PPp')}
                              </p>
                            </div>
                          </div>
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent>
                      <p className="text-sm md:text-base mb-4 whitespace-pre-wrap">{post.content}</p>
                      {post.image_url && (
                        <img
                          src={post.image_url}
                          alt="Post"
                          className="rounded-lg w-full mb-4"
                        />
                      )}
                      <div className="flex items-center gap-4 pt-4 border-t">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleLike(post.id)}
                          data-testid="feed-like-button"
                        >
                          <Heart className="h-4 w-4 mr-2" />
                          {post.likes_count}
                        </Button>
                        <Button variant="ghost" size="sm" data-testid="feed-comment-button">
                          <MessageCircle className="h-4 w-4 mr-2" />
                          {post.comments_count}
                        </Button>
                        <Button variant="ghost" size="sm" data-testid="feed-share-button">
                          <Share2 className="h-4 w-4 mr-2" />
                          Share
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              ))}
              {posts.length === 0 && (
                <Card>
                  <CardContent className="py-12 text-center">
                    <p className="text-muted-foreground">No posts yet. Be the first to share something!</p>
                  </CardContent>
                </Card>
              )}
            </div>
          </div>

          {/* Right Sidebar */}
          <div className="lg:col-span-5 space-y-6 mt-6 lg:mt-0">
            {/* Upcoming Events Widget */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: 0.1 }}
            >
              <Card>
                <CardHeader>
                  <div className="flex items-center gap-2">
                    <Calendar className="h-5 w-5 text-primary" />
                    <h3 className="heading-font font-semibold">Upcoming Events</h3>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  {events.slice(0, 3).map((event) => (
                    <div key={event.id} className="flex gap-3 p-3 rounded-lg hover:bg-muted/50 transition-colors cursor-pointer" data-testid="sidebar-event-item">
                      <div className="flex-shrink-0">
                        <div className="h-12 w-12 rounded-lg bg-primary/10 flex flex-col items-center justify-center">
                          <span className="text-xs font-medium text-primary">
                            {format(new Date(event.date), 'MMM')}
                          </span>
                          <span className="text-lg font-bold text-primary">
                            {format(new Date(event.date), 'd')}
                          </span>
                        </div>
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="heading-font text-sm font-semibold truncate">{event.title}</p>
                        <p className="text-xs text-muted-foreground truncate">{event.ngo_name}</p>
                        <Badge variant="secondary" className="mt-1 text-xs">
                          {event.volunteers_registered}/{event.volunteers_needed} volunteers
                        </Badge>
                      </div>
                    </div>
                  ))}
                  {events.length === 0 && (
                    <p className="text-sm text-muted-foreground text-center py-4">No upcoming events</p>
                  )}
                </CardContent>
              </Card>
            </motion.div>

            {/* Impact Stats Widget */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: 0.2 }}
            >
              <Card>
                <CardHeader>
                  <div className="flex items-center gap-2">
                    <TrendingUp className="h-5 w-5 text-[hsl(var(--brand-accent))]" />
                    <h3 className="heading-font font-semibold">Your Impact</h3>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-3">
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-muted-foreground">Volunteer Hours</span>
                      <span className="heading-font text-xl font-bold text-primary">0</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-muted-foreground">Events Attended</span>
                      <span className="heading-font text-xl font-bold text-[hsl(var(--brand-accent))]">0</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-muted-foreground">Total Donated</span>
                      <span className="heading-font text-xl font-bold text-[hsl(var(--brand-support))]">$0</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Feed;
