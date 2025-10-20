import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import { API } from '../App';
import { Navigation } from '../components/Navigation';
import { useAuth } from '../contexts/AuthContext';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '../components/ui/avatar';
import { Badge } from '../components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../components/ui/tabs';
import { Calendar, Heart, TrendingUp } from 'lucide-react';
import { motion } from 'framer-motion';

const Profile = () => {
  const { userId } = useParams();
  const { user: currentUser } = useAuth();
  const [user, setUser] = useState(null);
  const [stats, setStats] = useState(null);

  useEffect(() => {
    fetchUserProfile();
    fetchUserStats();
  }, [userId]);

  const fetchUserProfile = async () => {
    try {
      const response = await axios.get(`${API}/users/${userId}`);
      setUser(response.data);
    } catch (error) {
      console.error('Error fetching user profile:', error);
    }
  };

  const fetchUserStats = async () => {
    try {
      const response = await axios.get(`${API}/users/${userId}/stats`);
      setStats(response.data);
    } catch (error) {
      console.error('Error fetching user stats:', error);
    }
  };

  if (!user || !stats) {
    return (
      <div className="min-h-screen bg-background">
        <Navigation />
        <div className="flex items-center justify-center py-16">
          <div className="animate-pulse text-lg heading-font">Loading profile...</div>
        </div>
      </div>
    );
  }

  const isOwnProfile = currentUser?.id === userId;

  return (
    <div className="min-h-screen bg-background">
      <Navigation />
      <div className="mx-auto px-4 sm:px-6 lg:px-8 max-w-5xl py-8">
        {/* Profile Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <Card className="mb-6">
            <div
              className="h-32 sm:h-48 rounded-t-xl"
              style={{ background: 'linear-gradient(135deg, hsl(28 85% 72%), hsl(165 60% 65%))' }}
            />
            <CardContent className="relative pt-16 sm:pt-20">
              <Avatar className="absolute -top-16 left-6 h-32 w-32 ring-4 ring-background">
                <AvatarImage src={user.avatar} />
                <AvatarFallback className="text-4xl">{user.name?.[0]}</AvatarFallback>
              </Avatar>
              <div className="ml-40 sm:ml-44">
                <div className="flex items-center gap-3 mb-2">
                  <h1 className="heading-font text-2xl sm:text-3xl font-bold">{user.name}</h1>
                  <Badge>{user.user_type}</Badge>
                </div>
                <p className="text-muted-foreground mb-4">{user.email}</p>
                {user.bio && <p className="text-sm">{user.bio}</p>}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* Stats Grid */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className="grid md:grid-cols-3 gap-6 mb-6"
        >
          <Card>
            <CardHeader>
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
                  <Calendar className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <CardTitle className="heading-font text-2xl">{stats.volunteer_hours}</CardTitle>
                  <p className="text-sm text-muted-foreground">Volunteer Hours</p>
                </div>
              </div>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-lg bg-[hsl(var(--brand-accent))]/10 flex items-center justify-center">
                  <TrendingUp className="h-5 w-5 text-[hsl(var(--brand-accent))]" />
                </div>
                <div>
                  <CardTitle className="heading-font text-2xl">{stats.events_registered}</CardTitle>
                  <p className="text-sm text-muted-foreground">Events Attended</p>
                </div>
              </div>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-lg bg-[hsl(var(--brand-support))]/10 flex items-center justify-center">
                  <Heart className="h-5 w-5 text-[hsl(var(--brand-support))]" />
                </div>
                <div>
                  <CardTitle className="heading-font text-2xl">${stats.total_donated}</CardTitle>
                  <p className="text-sm text-muted-foreground">Total Donated</p>
                </div>
              </div>
            </CardHeader>
          </Card>
        </motion.div>

        {/* Content Tabs */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <Card>
            <CardContent className="pt-6">
              <Tabs defaultValue="about">
                <TabsList className="grid w-full grid-cols-3" data-testid="profile-tabs">
                  <TabsTrigger value="about">About</TabsTrigger>
                  <TabsTrigger value="activity">Activity</TabsTrigger>
                  <TabsTrigger value="impact">Impact</TabsTrigger>
                </TabsList>
                <TabsContent value="about" className="space-y-4 mt-6">
                  <div>
                    <h3 className="heading-font font-semibold mb-2">Skills</h3>
                    <div className="flex flex-wrap gap-2">
                      {user.skills && user.skills.length > 0 ? (
                        user.skills.map((skill, i) => <Badge key={i} variant="secondary">{skill}</Badge>)
                      ) : (
                        <p className="text-sm text-muted-foreground">No skills listed</p>
                      )}
                    </div>
                  </div>
                  <div>
                    <h3 className="heading-font font-semibold mb-2">Interests</h3>
                    <div className="flex flex-wrap gap-2">
                      {user.interests && user.interests.length > 0 ? (
                        user.interests.map((interest, i) => <Badge key={i} variant="outline">{interest}</Badge>)
                      ) : (
                        <p className="text-sm text-muted-foreground">No interests listed</p>
                      )}
                    </div>
                  </div>
                </TabsContent>
                <TabsContent value="activity" className="mt-6">
                  <p className="text-sm text-muted-foreground text-center py-8">Activity feed coming soon</p>
                </TabsContent>
                <TabsContent value="impact" className="mt-6">
                  <p className="text-sm text-muted-foreground text-center py-8">Impact visualization coming soon</p>
                </TabsContent>
              </Tabs>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  );
};

export default Profile;
