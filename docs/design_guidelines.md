{
  "meta": {
    "product_name": "Seva-Setu",
    "tagline": "Where NGOs, volunteers, and donors meet to create impact",
    "brand_attributes": ["trustworthy", "warm", "community-first", "modern", "accessible"],
    "audience": ["NGOs", "Volunteers", "Donors", "Social impact enthusiasts"],
    "mobile_first": true
  },
  "visual_personality": {
    "style_mix": "Swiss layout structure + Humanist warmth + Soft glass accents",
    "layout_style": "Bento grid + Card layout with asymmetrical highlights",
    "tone": "Inviting and optimistic; data-focused where needed",
    "do_not_use": ["harsh neon", "over-saturated gradients", "purple for chat/messaging", "centered app container"]
  },
  "typography": {
    "fonts": {
      "heading": {
        "family": "Space Grotesk",
        "import": "https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap"
      },
      "body": {
        "family": "Figtree",
        "import": "https://fonts.googleapis.com/css2?family=Figtree:wght@400;500;600;700&display=swap"
      },
      "mono": {
        "family": "Source Code Pro",
        "import": "https://fonts.googleapis.com/css2?family=Source+Code+Pro:wght@400;500;700&display=swap"
      }
    },
    "scale": {
      "h1": "text-4xl sm:text-5xl lg:text-6xl font-semibold tracking-tight",
      "h2": "text-base md:text-lg font-semibold tracking-tight text-foreground/90",
      "h3": "text-lg md:text-xl font-semibold",
      "body": "text-sm md:text-base leading-relaxed",
      "small": "text-xs leading-snug text-muted-foreground"
    },
    "utility": {
      "heading_class": "font-[Space_Grotesk]",
      "body_class": "font-[Figtree]"
    },
    "rules": [
      "Use tighter letter-spacing for headings (-0.01em to -0.02em)",
      "Maintain at least 1.6 line-height for paragraphs",
      "Never center the entire app container"
    ]
  },
  "color_system": {
    "semantic_tokens": {
      "--brand-primary": "165 60% 38%", 
      "--brand-accent": "28 85% 58%", 
      "--brand-support": "204 65% 48%", 
      "--brand-calm": "45 96% 62%", 
      "--success": "149 55% 36%",
      "--warning": "31 92% 52%",
      "--error": "4 74% 55%",
      "--info": "200 80% 40%",
      "--surface-1": "0 0% 100%",
      "--surface-2": "210 20% 98%",
      "--surface-3": "210 16% 96%",
      "--ink-1": "222 16% 16%",
      "--ink-2": "222 10% 32%",
      "--ink-3": "222 6% 46%",
      "--ring-strong": "165 60% 38%"
    },
    "map_to_tailwind_tokens": {
      "--background": "var(--surface-2)",
      "--foreground": "var(--ink-1)",
      "--card": "var(--surface-1)",
      "--card-foreground": "var(--ink-1)",
      "--primary": "var(--brand-primary)",
      "--primary-foreground": "0 0% 98%",
      "--secondary": "var(--surface-3)",
      "--secondary-foreground": "var(--ink-1)",
      "--accent": "var(--brand-accent)",
      "--accent-foreground": "0 0% 98%",
      "--muted": "210 16% 96%",
      "--muted-foreground": "var(--ink-3)",
      "--border": "210 16% 90%",
      "--input": "210 16% 90%",
      "--ring": "var(--ring-strong)",
      "--destructive": "var(--error)",
      "--destructive-foreground": "0 0% 98%"
    },
    "contrast_notes": [
      "All text on brand and accent surfaces must meet WCAG AA (>= 4.5:1)",
      "Prefer dark ink colors (#171a1c) on light surfaces"
    ]
  },
  "gradients_and_texture": {
    "hero_gradient": "linear-gradient(120deg, hsl(45 96% 96%) 0%, hsl(195 80% 96%) 55%, hsl(160 55% 94%) 100%)",
    "accent_ribbon": "linear-gradient(135deg, hsl(28 85% 72%), hsl(165 60% 65%))",
    "allowed_usage": ["hero background", "section separators", "large CTA banners (light only)"],
    "noise_overlay_css": ".noise-bg:before { content: ''; position: absolute; inset: 0; pointer-events: none; background-image: url('data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"140\" height=\"140\"><filter id=\"n\"><feTurbulence type=\"fractalNoise\" baseFrequency=\"0.9\" numOctaves=\"2\" stitchTiles=\"stitch\"/></filter><rect width=\"100%\" height=\"100%\" filter=\"url(%23n)\" opacity=\"0.03\"/></svg>'); }",
    "restrictions": [
      "Never exceed 20% of viewport with gradients",
      "Never apply gradients to text-heavy blocks or small UI elements",
      "Avoid purple/pink dark blends; keep tones light and airy"
    ]
  },
  "layout_and_grid": {
    "container": {
      "max_widths": {"sm": "640px", "md": "768px", "lg": "1024px", "xl": "1280px", "2xl": "1440px"},
      "class": "mx-auto px-4 sm:px-6 lg:px-8"
    },
    "grid_system": {
      "mobile": "grid-cols-1 gap-4",
      "tablet": "md:grid-cols-6 md:gap-5",
      "desktop": "lg:grid-cols-12 lg:gap-6"
    },
    "page_scaffolds": {
      "home_landing": "sticky top-0 z-50 nav; hero with soft gradient + stats; 3-up value cards; feed preview; CTA banner",
      "social_feed": "3-column on desktop (feed lg:col-span-7, right rail widgets lg:col-span-5), single column on mobile",
      "messaging": "split view at lg (threads list 1/3, conversation 2/3); single column with drawer for threads on mobile",
      "events": "filters atop; event cards in responsive masonry; calendar drawer for date pick; event detail sheet",
      "profile": "header cover + avatar; tabs for Posts | Events | Impact | About; stats bento",
      "donations": "trust badges + suggested amounts; impact breakdown; Stripe checkout CTA",
      "analytics": "bento with KPIs top row and charts below; export and filter bar",
      "search": "filters left on desktop; results list/grid; saved searches chip row"
    }
  },
  "tokens_css": {
    "paste_into_index_css": [
      ":root { --brand-primary: 165 60% 38%; --brand-accent: 28 85% 58%; --brand-support: 204 65% 48%; --brand-calm: 45 96% 62%; --ring-strong: 165 60% 38%; --success: 149 55% 36%; --warning: 31 92% 52%; --error: 4 74% 55%; --info: 200 80% 40%; --surface-1: 0 0% 100%; --surface-2: 210 20% 98%; --surface-3: 210 16% 96%; --ink-1: 222 16% 16%; --ink-2: 222 10% 32%; --ink-3: 222 6% 46%; }",
      "body { font-family: 'Figtree', system-ui, -apple-system, Segoe UI, Roboto, 'Helvetica Neue', Arial, sans-serif; }",
      ".heading-font { font-family: 'Space Grotesk', ui-sans-serif, system-ui; }"
    ]
  },
  "component_path": {
    "base": {
      "button": "./components/ui/button.jsx",
      "card": "./components/ui/card.jsx",
      "avatar": "./components/ui/avatar.jsx",
      "badge": "./components/ui/badge.jsx",
      "tabs": "./components/ui/tabs.jsx",
      "dialog": "./components/ui/dialog.jsx",
      "sheet": "./components/ui/sheet.jsx",
      "dropdown": "./components/ui/dropdown-menu.jsx",
      "calendar": "./components/ui/calendar.jsx",
      "input": "./components/ui/input.jsx",
      "textarea": "./components/ui/textarea.jsx",
      "select": "./components/ui/select.jsx",
      "checkbox": "./components/ui/checkbox.jsx",
      "switch": "./components/ui/switch.jsx",
      "progress": "./components/ui/progress.jsx",
      "popover": "./components/ui/popover.jsx",
      "tooltip": "./components/ui/tooltip.jsx",
      "toast": "./components/ui/sonner.jsx",
      "table": "./components/ui/table.jsx",
      "accordion": "./components/ui/accordion.jsx",
      "pagination": "./components/ui/pagination.jsx",
      "separator": "./components/ui/separator.jsx",
      "hover_card": "./components/ui/hover-card.jsx",
      "skeleton": "./components/ui/skeleton.jsx",
      "carousel": "./components/ui/carousel.jsx"
    }
  },
  "buttons_system": {
    "tokens": {
      "--btn-radius": "0.625rem",
      "--btn-shadow": "0 4px 14px rgba(0,0,0,0.06)",
      "--btn-focus": "0 0 0 3px hsl(var(--ring) / 0.3)"
    },
    "variants": {
      "primary": "bg-[hsl(var(--brand-primary))] text-white hover:bg-[hsl(var(--brand-primary))]/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[hsl(var(--brand-primary))]",
      "secondary": "bg-white/70 backdrop-blur border border-white/60 shadow-sm hover:bg-white focus-visible:ring-2 focus-visible:ring-[hsl(var(--brand-support))]",
      "ghost": "bg-transparent hover:bg-[hsl(var(--surface-3))]"
    },
    "sizes": {
      "sm": "h-9 px-3",
      "md": "h-11 px-4",
      "lg": "h-12 px-6"
    },
    "motion": "hover:shadow-md transition-colors duration-200 disabled:opacity-50 data-[state=loading]:cursor-wait"
  },
  "motion_and_microinteractions": {
    "library": "framer-motion",
    "install": "npm i framer-motion",
    "principles": [
      "Use entrance fade+rise (20-30px) for cards",
      "No universal transitions; apply to interactive elements only",
      "Respect prefers-reduced-motion"
    ],
    "snippets_jsx": {
      "card_enter": "import { motion } from 'framer-motion'\nexport const FadeCard = ({ children }) => (\n  <motion.div initial={{ opacity: 0, y: 24 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: '-80px' }} transition={{ duration: 0.5, ease: 'easeOut' }}>{children}</motion.div>\n)",
      "button_ripple": "// Use focus-visible ring and subtle scale\n<button data-testid=\"primary-cta-button\" className=\"active:scale-[0.98] transition-[background-color,box-shadow] duration-200\">Donate</button>"
    }
  },
  "feature_blueprints": {
    "social_feed": {
      "layout": "lg:grid lg:grid-cols-12 lg:gap-6", 
      "columns": {
        "main": "lg:col-span-7 space-y-4",
        "aside": "lg:col-span-5 space-y-4"
      },
      "components": ["card", "avatar", "button", "badge", "dropdown", "tabs", "skeleton", "tooltip"],
      "post_card_classes": "bg-card rounded-xl border p-4 sm:p-5 shadow-sm",
      "interactions": ["like", "comment", "share", "save"],
      "data_testids": [
        "feed-create-post-button", "feed-post-card", "feed-like-button", "feed-comment-input", "feed-share-menu"
      ],
      "sample_component_js": "import { Card } from './components/ui/card.jsx'\nimport { Avatar } from './components/ui/avatar.jsx'\nimport { Button } from './components/ui/button.jsx'\nexport const FeedPost = ({ post }) => (\n  <Card data-testid=\"feed-post-card\" className=\"bg-card border rounded-xl p-4 sm:p-5\">\n    <div className=\"flex items-start gap-3\">\n      <Avatar data-testid=\"post-author-avatar\" className=\"h-10 w-10\" />\n      <div className=\"flex-1\">\n        <div className=\"flex items-center gap-2\">\n          <span className=\"heading-font font-semibold text-sm\">{post.author}</span>\n          <span className=\"text-xs text-muted-foreground\">{post.time}</span>\n        </div>\n        <p className=\"mt-2 text-sm md:text-base\">{post.text}</p>\n        {post.image && <img alt=\"\" className=\"mt-3 rounded-lg\" src={post.image} />}\n        <div className=\"mt-3 flex items-center gap-3\">\n          <Button data-testid=\"feed-like-button\" variant=\"ghost\" className=\"text-[hsl(var(--brand-primary))]\">Like</Button>\n          <Button data-testid=\"feed-comment-button\" variant=\"ghost\">Comment</Button>\n          <Button data-testid=\"feed-share-button\" variant=\"ghost\">Share</Button>\n        </div>\n      </div>\n    </div>\n  </Card>\n)"
    },
    "messaging": {
      "layout": "lg:grid lg:grid-cols-12 lg:gap-6",
      "columns": {
        "threads": "lg:col-span-4 border rounded-xl bg-card",
        "conversation": "lg:col-span-8 border rounded-xl bg-card"
      },
      "components": ["input", "button", "avatar", "scroll-area", "sheet", "dropdown", "tooltip"],
      "data_testids": ["message-thread-item", "message-input", "message-send-button", "message-attachment-button"],
      "message_bubble_classes": {
        "me": "ml-auto bg-[hsl(var(--brand-primary))] text-white max-w-[78%] rounded-2xl rounded-tr-sm px-3 py-2",
        "them": "mr-auto bg-secondary text-foreground max-w-[78%] rounded-2xl rounded-tl-sm px-3 py-2"
      },
      "sample_component_js": "import { Input } from './components/ui/input.jsx'\nimport { Button } from './components/ui/button.jsx'\nexport const MessageComposer = ({ onSend }) => {\n  const [v, setV] = React.useState('')\n  return (\n    <div className=\"border-t p-3 flex gap-2\">\n      <Input data-testid=\"message-input\" value={v} onChange={(e)=>setV(e.target.value)} placeholder=\"Write a message...\" className=\"flex-1\"/>\n      <Button data-testid=\"message-send-button\" onClick={()=>onSend(v)} className=\"min-w-20\">Send</Button>\n    </div>\n  )\n}"
    },
    "events": {
      "overview": "Filters + grid of event cards; calendar popover for date range; RSVP drawer",
      "components": ["card", "calendar", "select", "badge", "button", "dialog", "sheet", "tabs"],
      "event_card_classes": "group relative overflow-hidden bg-card rounded-xl border p-4 hover:shadow-md transition-shadow duration-200",
      "data_testids": ["event-card", "event-rsvp-button", "event-filter-select", "event-date-picker"],
      "sample_component_js": "import { Calendar } from './components/ui/calendar.jsx'\nimport { Card } from './components/ui/card.jsx'\nexport const EventCard = ({ e }) => (\n  <Card data-testid=\"event-card\" className=\"group p-4 rounded-xl border\">\n    <img alt=\"\" src={e.cover} className=\"rounded-lg aspect-[16/9] object-cover\"/>\n    <div className=\"mt-3 flex items-center justify-between\">\n      <div>\n        <h3 className=\"heading-font text-base font-semibold\">{e.title}</h3>\n        <p className=\"text-xs text-muted-foreground\">{e.date} • {e.location}</p>\n      </div>\n      <button data-testid=\"event-rsvp-button\" className=\"h-9 px-3 rounded-md bg-[hsl(var(--brand-support))] text-white\">RSVP</button>\n    </div>\n  </Card>\n)"
    },
    "profiles": {
      "header": "cover image + avatar overlap; CTA buttons; stats row",
      "components": ["avatar", "tabs", "button", "badge", "card"],
      "data_testids": ["profile-edit-button", "profile-follow-button", "profile-tab"],
      "classes": {
        "cover": "relative h-40 sm:h-56 rounded-xl overflow-hidden bg-gradient-to-r from-amber-50 via-sky-50 to-emerald-50",
        "avatar": "absolute -bottom-8 left-4 h-20 w-20 ring-4 ring-white rounded-full"
      }
    },
    "donations": {
      "principles": ["Show trust badges", "Short, clear form", "One-time vs monthly toggle", "Transparent impact metrics"],
      "components": ["card", "input", "radio-group", "switch", "button", "dialog", "progress", "badge"],
      "data_testids": ["donation-amount-input", "donation-submit-button", "donation-frequency-toggle"],
      "stripe": {
        "note": "Use Stripe Elements; place processing state with progress and sonner toast",
        "cta_class": "bg-[hsl(var(--brand-accent))] text-white hover:bg-[hsl(var(--brand-accent))]/90"
      }
    },
    "analytics": {
      "library": "Recharts",
      "install": "npm i recharts",
      "components": ["card", "tabs", "select", "badge", "table"],
      "data_testids": ["analytics-kpi-card", "analytics-chart", "analytics-filter-select"],
      "sample_chart_js": "import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip } from 'recharts'\nexport const ImpactChart = ({ data }) => (\n  <div data-testid=\"analytics-chart\" className=\"h-64\">\n    <ResponsiveContainer width=\"100%\" height=\"100%\">\n      <AreaChart data={data}>\n        <defs>\n          <linearGradient id=\"g\" x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1\">\n            <stop offset=\"0%\" stopColor=\"hsl(var(--brand-primary))\" stopOpacity={0.35} />\n            <stop offset=\"100%\" stopColor=\"hsl(var(--brand-primary))\" stopOpacity={0.02} />\n          </linearGradient>\n        </defs>\n        <XAxis dataKey=\"name\" tick={{ fontSize: 12 }} />\n        <YAxis tick={{ fontSize: 12 }} />\n        <Tooltip />\n        <Area type=\"monotone\" dataKey=\"value\" stroke=\"hsl(var(--brand-primary))\" fill=\"url(#g)\" />\n      </AreaChart>\n    </ResponsiveContainer>\n  </div>\n)"
    },
    "notifications": {
      "components": ["toast", "badge", "dropdown", "tabs"],
      "data_testids": ["notification-icon-button", "notification-item", "mark-all-read-button"],
      "usage": "Use sonner for toasts; notification center as dropdown/sheet with tabs for All / Mentions / System"
    },
    "search_and_discovery": {
      "components": ["input", "select", "tabs", "card", "badge", "pagination"],
      "data_testids": ["global-search-input", "filter-chip", "result-card"],
      "patterns": ["chips for causes (Education, Health, Environment)", "facet filters with badge counters"]
    }
  },
  "accessibility": {
    "rules": [
      "All interactive elements must have visible focus states (2px ring using --ring)",
      "Keyboard navigable menus and dialogs (Escape closes, arrows navigate)",
      "ARIA labels for icons-only buttons",
      "Test color contrast for all text (WCAG AA)",
      "Respect prefers-reduced-motion media query"
    ],
    "testing_attributes": {
      "requirement": "Every interactive or key informational element MUST include data-testid using kebab-case",
      "examples": [
        "login-form-submit-button", "feed-post-card", "event-rsvp-button", "message-send-button"
      ]
    }
  },
  "images_urls": [
    {
      "category": "hero",
      "description": "Hands-in team huddle (community unity)",
      "url": "https://images.unsplash.com/photo-1630068846062-3ffe78aa5049?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2Njd8MHwxfHNlYXJjaHwxfHxjb21tdW5pdHklMjB2b2x1bnRlZXJpbmclMjBkaXZlcnNlJTIwZ3JvdXAlMjB3YXJtJTIwbGlnaHR8ZW58MHx8fHwxNzYwNzA0NzkxfDA&ixlib=rb-4.1.0&q=85"
    },
    {
      "category": "feed-cover",
      "description": "Volunteers in yellow shirts",
      "url": "https://images.unsplash.com/photo-1560220604-1985ebfe28b1?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2Njd8MHwxfHNlYXJjaHwyfHxjb21tdW5pdHklMjB2b2x1bnRlZXJpbmclMjBkaXZlcnNlJTIwZ3JvdXAlMjB3YXJtJTIwbGlnaHR8ZW58MHx8fHwxNzYwNzA0NzkxfDA&ixlib=rb-4.1.0&q=85"
    },
    {
      "category": "events",
      "description": "Community tasting/event scene",
      "url": "https://images.unsplash.com/photo-1743793174491-bcbdf1882ad5?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2Njd8MHwxfHNlYXJjaHwzfHxjb21tdW5pdHklMjB2b2x1bnRlZXJpbmclMjBkaXZlcnNlJTIwZ3JvdXAlMjB3YXJtJTIwbGlnaHR8ZW58MHx8fHwxNzYwNzA0NzkxfDA&ixlib=rb-4.1.0&q=85"
    },
    {
      "category": "events",
      "description": "Group listening to presenter under a tent",
      "url": "https://images.unsplash.com/photo-1755718669605-e0c89e2ea60c?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2Njd8MHwxfHNlYXJjaHw0fHxjb21tdW5pdHklMjB2b2x1bnRlZXJpbmclMjBkaXZlcnNlJTIwZ3JvdXAlMjB3YXJtJTIwbGlnaHR8ZW58MHx8fHwxNzYwNzA0NzkxfDA&ixlib=rb-4.1.0&q=85"
    },
    {
      "category": "profile/testimonials",
      "description": "Volunteers sorting donations indoors",
      "url": "https://images.pexels.com/photos/6994857/pexels-photo-6994857.jpeg"
    },
    {
      "category": "community",
      "description": "Diverse group outdoors by the sea",
      "url": "https://images.pexels.com/photos/8777886/pexels-photo-8777886.jpeg"
    }
  ],
  "libraries_and_setup": {
    "packages": [
      {"name": "framer-motion", "install": "npm i framer-motion"},
      {"name": "recharts", "install": "npm i recharts"},
      {"name": "@radix-ui/react-icons", "install": "npm i @radix-ui/react-icons"}
    ],
    "sonner": {
      "path": "./components/ui/sonner.jsx",
      "usage": "import { Toaster } from './components/ui/sonner.jsx' and show toast.success/error on key actions"
    },
    "notes": [
      "Do not implement native dropdowns/menus; use shadcn components from ./components/ui/",
      "All new components must be named exports (export const Component = ...)"
    ]
  },
  "micro_states": {
    "hover": "shadow-sm -> shadow-md on cards; color-emphasis on icons",
    "press": "scale to 0.98 for buttons",
    "focus": "ring-2 ring-[hsl(var(--ring))] offset-2",
    "loading": "opacity-70 + spinner + aria-busy=true",
    "empty": {
      "feed": "Card with illustration placeholder and CTA to follow NGOs",
      "events": "Card with calendar graphic and CTA to explore by cause"
    }
  },
  "page_wires": {
    "hero": {
      "classes": "relative overflow-hidden rounded-2xl bg-white noise-bg",
      "inner": "px-6 py-10 sm:py-14 lg:px-10",
      "headline": "heading-font text-4xl sm:text-5xl lg:text-6xl",
      "subcopy": "text-sm md:text-base text-ink-3 max-w-prose"
    },
    "right_rail_widgets": ["Upcoming Events", "Impact Stats", "Suggested NGOs", "Causes"]
  },
  "search_references": {
    "dribbble": [
      "https://dribbble.com/tags/volunteer-app",
      "https://dribbble.com/tags/donation-platform"
    ],
    "behance": [
      "https://www.behance.net/search/projects/ngo%20app%20ui%20design?locale=en_US"
    ],
    "live_inspo": [
      "https://www.milliegiving.com"
    ]
  },
  "instructions_to_main_agent": [
    "1) Add Space Grotesk and Figtree imports in index.html or layout and apply heading-font/body classes globally.",
    "2) Paste tokens_css entries into src/index.css under :root, mapping to existing shadcn tokens as provided.",
    "3) Build pages using feature_blueprints and layout_and_grid page_scaffolds.",
    "4) Use only components from ./components/ui/ for dropdowns, dialogs, calendars, toasts, selects.",
    "5) Add data-testid to every interactive/key informational element using kebab-case.",
    "6) Keep gradients limited to hero and large banners; never on text-heavy or small elements.",
    "7) Use framer-motion snippets for entrance and subtle interactions; respect prefers-reduced-motion.",
    "8) For analytics, add Recharts and the ImpactChart example; use tokens for colors.",
    "9) For events, use calendar.jsx for date pickers and dialog/sheet for RSVP flows.",
    "10) Use sonner.jsx Toaster at root; trigger toast on RSVP, message sent, donation complete.",
    "11) Ensure mobile-first: single-column on mobile, progressive enhancement to grids on md+.",
    "12) Apply generous spacing (py-8 sections; gap-6 in grids) and avoid cramped layouts."
  ]
}

<General UI UX Design Guidelines>  
    - You must **not** apply universal transition. Eg: `transition: all`. This results in breaking transforms. Always add transitions for specific interactive elements like button, input excluding transforms
    - You must **not** center align the app container, ie do not add `.App { text-align: center; }` in the css file. This disrupts the human natural reading flow of text
   - NEVER: use AI assistant Emoji characters like`🤖🧠💭💡🔮🎯📚🎭🎬🎪🎉🎊🎁🎀🎂🍰🎈🎨🎰💰💵💳🏦💎🪙💸🤑📊📈📉💹🔢🏆🥇 etc for icons. Always use **FontAwesome cdn** or **lucid-react** library already installed in the package.json

 **GRADIENT RESTRICTION RULE**
NEVER use dark/saturated gradient combos (e.g., purple/pink) on any UI element.  Prohibited gradients: blue-500 to purple 600, purple 500 to pink-500, green-500 to blue-500, red to pink etc
NEVER use dark gradients for logo, testimonial, footer etc
NEVER let gradients cover more than 20% of the viewport.
NEVER apply gradients to text-heavy content or reading areas.
NEVER use gradients on small UI elements (<100px width).
NEVER stack multiple gradient layers in the same viewport.

**ENFORCEMENT RULE:**
    • Id gradient area exceeds 20% of viewport OR affects readability, **THEN** use solid colors

**How and where to use:**
   • Section backgrounds (not content backgrounds)
   • Hero section header content. Eg: dark to light to dark color
   • Decorative overlays and accent elements only
   • Hero section with 2-3 mild color
   • Gradients creation can be done for any angle say horizontal, vertical or diagonal

- For AI chat, voice application, **do not use purple color. Use color like light green, ocean blue, peach orange etc**

</Font Guidelines>

- Every interaction needs micro-animations - hover states, transitions, parallax effects, and entrance animations. Static = dead. 
   
- Use 2-3x more spacing than feels comfortable. Cramped designs look cheap.

- Subtle grain textures, noise overlays, custom cursors, selection states, and loading animations: separates good from extraordinary.
   
- Before generating UI, infer the visual style from the problem statement (palette, contrast, mood, motion) and immediately instantiate it by setting global design tokens (primary, secondary/accent, background, foreground, ring, state colors), rather than relying on any library defaults. Don't make the background dark as a default step, always understand problem first and define colors accordingly
    Eg: - if it implies playful/energetic, choose a colorful scheme
           - if it implies monochrome/minimal, choose a black–white/neutral scheme

**Component Reuse:**
	- Prioritize using pre-existing components from src/components/ui when applicable
	- Create new components that match the style and conventions of existing components when needed
	- Examine existing components to understand the project's component patterns before creating new ones

**IMPORTANT**: Do not use HTML based component like dropdown, calendar, toast etc. You **MUST** always use `/app/frontend/src/components/ui/ ` only as a primary components as these are modern and stylish component

**Best Practices:**
	- Use Shadcn/UI as the primary component library for consistency and accessibility
	- Import path: ./components/[component-name]

**Export Conventions:**
	- Components MUST use named exports (export const ComponentName = ...)
	- Pages MUST use default exports (export default function PageName() {...})

**Toasts:**
  - Use `sonner` for toasts" 
  - Sonner component are located in `/app/src/components/ui/sonner.tsx`

Use 2–4 color gradients, subtle textures/noise overlays, or CSS-based noise to avoid flat visuals.
</General UI UX Design Guidelines>
