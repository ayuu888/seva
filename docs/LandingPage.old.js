import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useAuth } from '../contexts/AuthContext';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../components/ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../components/ui/select';
import { ThemeToggle } from '../components/ThemeToggle';
import { toast } from 'sonner';
import { Heart, Users, Calendar, TrendingUp } from 'lucide-react';

const LandingPage = () => {
  const { register, login, loginWithGoogle } = useAuth();
  const [isLogin, setIsLogin] = useState(true);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    userType: 'volunteer'
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      if (isLogin) {
        await login(formData.email, formData.password);
        toast.success('Welcome back!');
      } else {
        await register(formData.name, formData.email, formData.password, formData.userType);
        toast.success('Account created successfully!');
      }
    } catch (error) {
      toast.error(error.response?.data?.detail || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Hero Section */}
      <div className="relative overflow-hidden" style={{ background: 'linear-gradient(120deg, hsl(45 96% 96%) 0%, hsl(195 80% 96%) 55%, hsl(160 55% 94%) 100%)' }}>
        <div className="dark:bg-gradient-to-br dark:from-[hsl(222,47%,11%)] dark:via-[hsl(222,47%,7%)] dark:to-[hsl(222,47%,11%)] absolute inset-0 transition-opacity duration-500" />
        <div className="noise-bg absolute inset-0" />
        
        {/* Theme Toggle - Top Right Corner */}
        <div className="absolute top-6 right-6 z-50">
          <ThemeToggle />
        </div>
        
        <div className="relative mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl py-16 sm:py-24">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              <h1 className="heading-font text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight mb-6">
                Where <span className="text-primary">NGOs</span>, <span className="text-[hsl(var(--brand-accent))]">Volunteers</span>, and <span className="text-[hsl(var(--brand-support))]">Donors</span> Meet
              </h1>
              <p className="text-lg text-muted-foreground max-w-prose mb-8 leading-relaxed">
                Seva-Setu is the bridge connecting passionate individuals with meaningful causes.
                Join thousands making real impact in communities worldwide.
              </p>
              <div className="flex flex-wrap gap-4">
                <Button size="lg" onClick={() => setIsLogin(false)} className="h-12 px-8" data-testid="hero-get-started-button">
                  Get Started
                </Button>
                <Button size="lg" variant="outline" onClick={() => setIsLogin(true)} className="h-12 px-8" data-testid="hero-signin-button">
                  Sign In
                </Button>
              </div>

              {/* Stats */}
              <div className="grid grid-cols-3 gap-6 mt-12">
                <div>
                  <div className="heading-font text-3xl font-bold text-primary">10K+</div>
                  <div className="text-sm text-muted-foreground">Active NGOs</div>
                </div>
                <div>
                  <div className="heading-font text-3xl font-bold text-[hsl(var(--brand-accent))]">50K+</div>
                  <div className="text-sm text-muted-foreground">Volunteers</div>
                </div>
                <div>
                  <div className="heading-font text-3xl font-bold text-[hsl(var(--brand-support))]">$2M+</div>
                  <div className="text-sm text-muted-foreground">Donated</div>
                </div>
              </div>
            </motion.div>

            {/* Auth Card */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
            >
              <Card className="shadow-lg dark:bg-card/50 dark:backdrop-blur-xl dark:border-white/10" data-testid="auth-card">
                <CardHeader>
                  <CardTitle className="heading-font text-2xl">Join Seva-Setu</CardTitle>
                  <CardDescription>Create impact together</CardDescription>
                </CardHeader>
                <CardContent>
                  <Tabs value={isLogin ? 'login' : 'register'} onValueChange={(v) => setIsLogin(v === 'login')}>
                    <TabsList className="grid w-full grid-cols-2 mb-6">
                      <TabsTrigger value="login" data-testid="login-tab">Login</TabsTrigger>
                      <TabsTrigger value="register" data-testid="register-tab">Register</TabsTrigger>
                    </TabsList>

                    <form onSubmit={handleSubmit} className="space-y-4">
                      {!isLogin && (
                        <div className="space-y-2">
                          <Label htmlFor="name">Full Name</Label>
                          <Input
                            id="name"
                            name="name"
                            placeholder="John Doe"
                            value={formData.name}
                            onChange={handleChange}
                            required={!isLogin}
                            data-testid="name-input"
                          />
                        </div>
                      )}

                      <div className="space-y-2">
                        <Label htmlFor="email">Email</Label>
                        <Input
                          id="email"
                          name="email"
                          type="email"
                          placeholder="you@example.com"
                          value={formData.email}
                          onChange={handleChange}
                          required
                          data-testid="email-input"
                        />
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="password">Password</Label>
                        <Input
                          id="password"
                          name="password"
                          type="password"
                          placeholder="••••••••"
                          value={formData.password}
                          onChange={handleChange}
                          required
                          data-testid="password-input"
                        />
                      </div>

                      {!isLogin && (
                        <div className="space-y-2">
                          <Label htmlFor="userType">I am a</Label>
                          <Select value={formData.userType} onValueChange={(v) => setFormData({ ...formData, userType: v })}>
                            <SelectTrigger data-testid="user-type-select">
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="volunteer">Volunteer</SelectItem>
                              <SelectItem value="ngo">NGO Representative</SelectItem>
                              <SelectItem value="donor">Donor</SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                      )}

                      <Button type="submit" className="w-full" disabled={loading} data-testid="auth-submit-button">
                        {loading ? 'Please wait...' : (isLogin ? 'Sign In' : 'Create Account')}
                      </Button>
                    </form>

                    <div className="relative my-6">
                      <div className="absolute inset-0 flex items-center">
                        <span className="w-full border-t" />
                      </div>
                      <div className="relative flex justify-center text-xs uppercase">
                        <span className="bg-card px-2 text-muted-foreground">Or continue with</span>
                      </div>
                    </div>

                    <Button
                      type="button"
                      variant="outline"
                      className="w-full"
                      onClick={loginWithGoogle}
                      data-testid="google-login-button"
                    >
                      <svg className="mr-2 h-4 w-4" viewBox="0 0 24 24">
                        <path
                          d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                          fill="#4285F4"
                        />
                        <path
                          d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                          fill="#34A853"
                        />
                        <path
                          d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                          fill="#FBBC05"
                        />
                        <path
                          d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                          fill="#EA4335"
                        />
                      </svg>
                      Google
                    </Button>
                  </Tabs>
                </CardContent>
              </Card>
            </motion.div>
          </div>
        </div>
      </div>

      {/* Features Section */}
      <div className="py-16 sm:py-24 bg-background">
        <div className="mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="heading-font text-3xl sm:text-4xl font-bold mb-4">Why Choose Seva-Setu?</h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              A comprehensive platform designed to amplify social impact
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
            >
              <Card className="h-full hover:shadow-md transition-shadow dark:bg-card/50 dark:backdrop-blur-xl dark:border-white/10">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                    <Heart className="h-6 w-6 text-primary" />
                  </div>
                  <CardTitle className="heading-font">Connect & Impact</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-muted-foreground">
                    Find NGOs aligned with your values and make a direct impact through volunteering or donations.
                  </p>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.1 }}
            >
              <Card className="h-full hover:shadow-md transition-shadow dark:bg-card/50 dark:backdrop-blur-xl dark:border-white/10">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-[hsl(var(--brand-accent))]/10 flex items-center justify-center mb-4">
                    <Calendar className="h-6 w-6 text-[hsl(var(--brand-accent))]" />
                  </div>
                  <CardTitle className="heading-font">Events & Opportunities</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-muted-foreground">
                    Discover volunteering events and opportunities to contribute your time and skills to meaningful causes.
                  </p>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.2 }}
            >
              <Card className="h-full hover:shadow-md transition-shadow dark:bg-card/50 dark:backdrop-blur-xl dark:border-white/10">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-[hsl(var(--brand-support))]/10 flex items-center justify-center mb-4">
                    <TrendingUp className="h-6 w-6 text-[hsl(var(--brand-support))]" />
                  </div>
                  <CardTitle className="heading-font">Track Your Impact</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-muted-foreground">
                    Monitor your volunteer hours, donations, and see the real-world impact of your contributions.
                  </p>
                </CardContent>
              </Card>
            </motion.div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LandingPage;
