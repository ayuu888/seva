import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import axios from 'axios';
import { API } from '../App';
import { Navigation } from '../components/Navigation';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Badge } from '../components/ui/badge';
import { toast } from 'sonner';
import { MapPin, Calendar, Users, Clock } from 'lucide-react';
import { format } from 'date-fns';

const Events = () => {
  const [events, setEvents] = useState([]);
  const [registrations, setRegistrations] = useState(new Set());

  useEffect(() => {
    fetchEvents();
  }, []);

  const fetchEvents = async () => {
    try {
      const response = await axios.get(`${API}/events`);
      setEvents(response.data);
    } catch (error) {
      console.error('Error fetching events:', error);
    }
  };

  const handleRSVP = async (eventId) => {
    try {
      const response = await axios.post(`${API}/events/${eventId}/rsvp`);
      if (response.data.registered) {
        setRegistrations(new Set([...registrations, eventId]));
        toast.success('Successfully registered for event!');
      } else {
        const newRegs = new Set(registrations);
        newRegs.delete(eventId);
        setRegistrations(newRegs);
        toast.success('Registration cancelled');
      }
      fetchEvents();
    } catch (error) {
      toast.error('Failed to register');
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Navigation />
      <div className="mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl py-8">
        <div className="mb-8">
          <h1 className="heading-font text-3xl sm:text-4xl font-bold mb-2">Volunteer Events</h1>
          <p className="text-lg text-muted-foreground">Discover opportunities to make a difference in your community</p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {events.map((event, index) => (
            <motion.div
              key={event.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: index * 0.05 }}
            >
              <Card className="h-full hover:shadow-lg transition-shadow group" data-testid="event-card">
                {event.cover_image && (
                  <div className="relative h-48 overflow-hidden rounded-t-xl">
                    <img
                      src={event.cover_image}
                      alt={event.title}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                    <Badge className="absolute top-4 right-4">
                      {event.category}
                    </Badge>
                  </div>
                )}
                <CardHeader>
                  <CardTitle className="heading-font text-xl mb-2">{event.title}</CardTitle>
                  <p className="text-sm text-muted-foreground">{event.ngo_name}</p>
                </CardHeader>
                <CardContent className="space-y-4">
                  <p className="text-sm line-clamp-3">{event.description}</p>
                  <div className="space-y-2">
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <Calendar className="h-4 w-4" />
                      {format(new Date(event.date), 'PPP')}
                    </div>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <Clock className="h-4 w-4" />
                      {format(new Date(event.date), 'p')}
                    </div>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <MapPin className="h-4 w-4" />
                      {event.location}
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Users className="h-4 w-4 text-primary" />
                      <span className="heading-font font-semibold text-primary">
                        {event.volunteers_registered}/{event.volunteers_needed} volunteers
                      </span>
                    </div>
                  </div>
                  <Button
                    className="w-full"
                    onClick={() => handleRSVP(event.id)}
                    variant={registrations.has(event.id) ? "outline" : "default"}
                    data-testid="event-rsvp-button"
                  >
                    {registrations.has(event.id) ? 'Cancel RSVP' : 'Register Now'}
                  </Button>
                </CardContent>
              </Card>
            </motion.div>
          ))}
          {events.length === 0 && (
            <div className="col-span-full">
              <Card>
                <CardContent className="py-12 text-center">
                  <Calendar className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                  <h3 className="heading-font text-lg font-semibold mb-2">No Events Yet</h3>
                  <p className="text-muted-foreground">Check back soon for volunteering opportunities</p>
                </CardContent>
              </Card>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Events;
