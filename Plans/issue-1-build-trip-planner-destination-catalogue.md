# Issue #1: Build trip planner destination catalogue

## Original Issue

Build a static Astro site that serves as a modern holiday brochure / destination catalogue for Darren and Anthony to decide where to go on holiday. UK-based travellers.

## Design Doc

See `designs/2026-03-27-trip-planner-catalogue-design.md` for full design specification.

## Success Criteria

- [ ] Site builds successfully with `npm run build` and produces static HTML output
- [ ] Homepage loads and displays all 32 destination cards in a responsive grid
- [ ] Each destination card shows: photo, name, country, trip length, allergen safety badges
- [ ] Region filter tabs (All/Europe/Americas/Asia/Oceania/Africa) filter the card grid
- [ ] Each destination card links to its detail page at `/destinations/[slug]`
- [ ] Each detail page shows: hero image, quick facts bar, allergen badges, full content sections (Things to Do, The Vibe, Things to See, Allergen & Dietary Detail), supporting images
- [ ] All 32 destinations have complete, authentic content (no placeholder text, no AI slop)
- [ ] Allergen safety badges are colour-coded: green (4-5), amber (3), red (1-2)
- [ ] Site is responsive: 1 column on mobile, 2 on tablet, 3 on desktop
- [ ] All images load from Unsplash URLs and have descriptive alt text
- [ ] Content reads naturally — written as friend-to-friend recommendations, not generic travel copy
- [ ] Nut allergy and vegetarian ratings are honest and practical (especially frank about Asian destinations)
- [ ] Costs shown in GBP for hotel per night and return flights

## Implementation Plan

### Phase 1: Project Setup

- [ ] Create branch: `git checkout -b feature/issue-1-trip-planner-catalogue`

- [ ] Scaffold Astro project in the current directory. Run:
  ```bash
  npm create astro@latest . -- --template minimal --no-install --no-git --typescript strict
  ```
  Then install dependencies:
  ```bash
  npm install
  ```
  Then install Tailwind:
  ```bash
  npx astro add tailwind --yes
  ```
  Verify the build works: `npm run build`. Fix any issues before proceeding.
  Commit: `git add -A && git commit -m "Scaffold Astro project with Tailwind CSS"`

- [ ] Configure Astro content collection for destinations. Create `src/content.config.ts`:
  ```typescript
  import { defineCollection, z } from 'astro:content';
  import { glob } from 'astro/loaders';

  const destinations = defineCollection({
    loader: glob({ pattern: '**/*.md', base: './src/content/destinations' }),
    schema: z.object({
      title: z.string(),
      country: z.string(),
      region: z.enum(['europe', 'americas', 'asia', 'oceania', 'africa']),
      heroImage: z.string().url(),
      heroImageAlt: z.string(),
      images: z.array(z.object({
        url: z.string().url(),
        alt: z.string(),
      })),
      summary: z.string(),
      bestMonths: z.array(z.number().min(1).max(12)),
      tripLength: z.string(),
      hotelCostPerNight: z.number(),
      flightCostReturn: z.number(),
      nutAllergyRating: z.number().min(1).max(5),
      vegetarianRating: z.number().min(1).max(5),
      allergenNotes: z.string(),
      vegetarianNotes: z.string(),
    }),
  });

  export const collections = { destinations };
  ```
  Create the directory `src/content/destinations/` (empty for now).
  Verify build still works: `npm run build`.
  Commit: `git add -A && git commit -m "Add destinations content collection schema"`

### Phase 2: Layout & Components

- [ ] Create the base HTML layout at `src/layouts/BaseLayout.astro`. It should:
  - Include a `<!DOCTYPE html>` with lang="en"
  - Set viewport meta tag for responsive design
  - Use system font stack via Tailwind: `font-sans` class on body (Tailwind's default sans stack is fine)
  - Set page title via props: `{title} | Darren & Anthony's Trip Planner`
  - Include a meta description prop
  - Body should have `bg-stone-50 text-stone-800` classes for the warm neutral palette
  - Minimal structure: just a `<slot />` wrapped in a semantic `<main>`
  - Include a simple `<header>` with site name linking to `/` and a `<footer>` with a simple copyright

  Verify build: `npm run build`.
  Commit: `git add -A && git commit -m "Add base layout component"`

- [ ] Create the destination card component at `src/components/DestinationCard.astro`. Props:
  - `title`, `country`, `region`, `slug`, `heroImage`, `heroImageAlt`, `summary`, `tripLength`, `hotelCostPerNight`, `flightCostReturn`, `nutAllergyRating`, `vegetarianRating`

  The card should:
  - Be an `<a>` tag linking to `/destinations/{slug}`
  - Show hero image (use `loading="lazy"`, `decoding="async"`, cover fit, fixed aspect ratio 3:2 via Tailwind `aspect-[3/2]`)
  - Below the image: destination title (h3), country
  - One-line summary (truncated with `line-clamp-2`)
  - Quick facts row: trip length, hotel cost (£X/night), flight cost (£X return)
  - Allergen badges row: nut allergy rating badge + vegetarian rating badge
  - Badge colours: rating 4-5 = `bg-emerald-100 text-emerald-800`, 3 = `bg-amber-100 text-amber-800`, 1-2 = `bg-red-100 text-red-800`
  - Badge text: for nut allergy show "Nut Safe: X/5", for vegetarian show "Veggie: X/5"
  - Card styling: `bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow overflow-hidden`

  Verify build: `npm run build`.
  Commit: `git add -A && git commit -m "Add destination card component"`

- [ ] Create allergen badge component at `src/components/AllergenBadge.astro`. Props: `rating: number`, `label: string`. This is a small reusable badge used on both the card and detail page. Renders a `<span>` with the colour-coded background based on rating value (same colours as above). Shows `{label}: {rating}/5`.
  Verify build: `npm run build`.
  Commit: `git add -A && git commit -m "Add allergen badge component"`

### Phase 3: Homepage

- [ ] Create the homepage at `src/pages/index.astro`. This page should:
  - Use `BaseLayout` with title "Holiday Destinations"
  - Import and query all destinations from the content collection: `import { getCollection } from 'astro:content'; const destinations = await getCollection('destinations');`
  - Sort destinations alphabetically by title
  - **Hero section**: Full-width hero area at the top with:
    - Large heading: "Where to Next?" (use `text-5xl font-bold text-stone-900`)
    - Subheading: "A curated guide for Darren & Anthony — with allergen safety ratings for every destination" (use `text-xl text-stone-600 mt-4`)
    - Keep it simple — no hero image on the homepage, let the destination cards be the visual draw
  - **Filter bar**: A row of region filter buttons below the hero. Buttons for: All, Europe, Americas, Asia, Oceania, Africa. Style as pill buttons. Use `data-region` attributes. The filtering is done with a small inline `<script>` tag (this is the one exception to "no JS") that:
    - Adds click handlers to filter buttons
    - Shows/hides cards based on `data-region` attributes on each card wrapper
    - Highlights the active filter button
    - Also include a "Nut-safe only" toggle button that hides cards where `data-nut-rating` < 4
  - **Card grid**: A `<div>` with classes `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8`. Each card is wrapped in a `<div data-region="{region}" data-nut-rating="{nutAllergyRating}">` for filtering.
  - Render each destination using the `DestinationCard` component, passing `slug` as `destination.id`

  **Important**: For this to work, you need at least one destination file to exist. Create a minimal test destination file `src/content/destinations/barcelona.md` with valid frontmatter matching the schema (use a real Unsplash URL for Barcelona — search unsplash.com for "barcelona city" and use a photo URL like `https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800`). The body can be brief placeholder text for now — it will be replaced with real content later.

  Verify build: `npm run build`. Then verify the dev server: start `npm run dev` in the background, use `agent-browser` to screenshot the homepage at `http://localhost:4321/` and verify cards render correctly with the image, title, badges. Stop the dev server after verification.
  Commit: `git add -A && git commit -m "Add homepage with destination grid and filters"`

### Phase 4: Destination Detail Page

- [ ] Create the destination detail page at `src/pages/destinations/[slug].astro`. This page should:
  - Use `getCollection` and `getEntry` to load the destination data
  - Export a `getStaticPaths` function that returns all destination slugs:
    ```typescript
    import { getCollection } from 'astro:content';
    export async function getStaticPaths() {
      const destinations = await getCollection('destinations');
      return destinations.map((dest) => ({
        params: { slug: dest.id },
        props: { destination: dest },
      }));
    }
    ```
  - Use `BaseLayout` with the destination title
  - **Hero section**: Full-width image with gradient overlay and destination name + country overlaid
    - Image: `<img>` tag with `w-full h-[50vh] object-cover` classes
    - Gradient overlay: absolute positioned div with `bg-gradient-to-t from-black/60 to-transparent`
    - Text overlay: `<h1>` with title and `<p>` with country, positioned bottom-left, white text
  - **Quick facts bar**: A horizontal bar below the hero with:
    - Best time to visit (convert month numbers to month names, e.g., "Apr — Oct")
    - Trip length (e.g., "4-5 nights")
    - Hotel cost (e.g., "~£120/night")
    - Flight cost (e.g., "~£80 return")
    - Style as a grid of 4 items with icons (use simple text icons: 📅 🗓️ 🏨 ✈️) in a `bg-white rounded-xl shadow-sm p-6` container with negative margin to overlap the hero slightly
  - **Allergen safety section**: Prominently placed below quick facts. Show both badges (nut allergy + vegetarian) at large size with the `allergenNotes` and `vegetarianNotes` text below each badge.
  - **Content sections**: Render the markdown body content using `const { Content } = await destination.render();` and `<Content />`. Style the rendered markdown with Tailwind typography — install `@tailwindcss/typography` (`npm install @tailwindcss/typography`) and configure it. Add the plugin to the CSS file by adding `@plugin "@tailwindcss/typography";` after the existing `@plugin` line. Use the `prose prose-stone prose-lg max-w-none` classes on the content wrapper. **Important:** Check what the Tailwind config looks like after `astro add tailwind` — it likely creates a CSS file with `@import "tailwindcss"`. The typography plugin should be added in that same CSS file.
  - **Image gallery**: Below the content, show supporting images in a 2-column grid. Each image: `rounded-xl overflow-hidden` with `<img loading="lazy" decoding="async">` and alt text below.
  - **Navigation**: A "← Back to all destinations" link at the top and bottom of the page

  Verify build: `npm run build` (should work with the Barcelona test file).
  Start dev server, use `agent-browser` to screenshot `/destinations/barcelona` and verify layout.
  Commit: `git add -A && git commit -m "Add destination detail page template"`

### Phase 5: Destination Content — Europe (batch 1: 1-10)

Write the first 10 European destination markdown files. For each destination, create `src/content/destinations/{slug}.md` with complete frontmatter and body content.

**Content quality rules:**
- Write as if you're a well-travelled friend recommending the place
- Be specific — name actual streets, neighbourhoods, restaurants, markets
- Be honest about allergen risks — if a cuisine uses lots of nuts, say so plainly
- No AI slop: avoid "hidden gem", "vibrant tapestry", "a feast for the senses", "nestled", "bustling", "rich tapestry", "mecca for", "paradise for"
- Each body should have 4 sections: Things to Do, The Vibe, Things to See, Allergen & Dietary Detail
- Each section should be 2-4 paragraphs, 300-500 words total across all sections
- Use real Unsplash photo URLs. Search unsplash.com for each city name and pick 3 high-quality photos (1 hero + 2 supporting). Use the `?w=800` parameter for reasonable file sizes. Use the actual photo URLs from unsplash.com (format: `https://images.unsplash.com/photo-XXXXX?w=800`)

**Costs guidance (GBP, mid-range):**
- Hotel: 3-4 star, central location, per night
- Flights: return from London, economy, typical booking

- [ ] Create `src/content/destinations/barcelona.md` — Replace the test file with full content. Barcelona, Spain. Region: europe. Nut: 4, Veggie: 5. Flights ~£80, Hotel ~£120/night, 4-5 nights, Best months: Apr-Jun, Sep-Oct. Vibrant Mediterranean city, incredible architecture (Gaudi), beach culture, amazing food scene. Vegetarian paradise. Spanish cuisine generally nut-safe but check sauces. Mention La Boqueria market, Gothic Quarter, Park Güell, Sagrada Familia, El Born neighbourhood. Use real Unsplash Barcelona photos.

- [ ] Create `src/content/destinations/lisbon.md` — Lisbon, Portugal. Region: europe. Nut: 4, Veggie: 4. Flights ~£70, Hotel ~£100/night, 3-4 nights, Best: Mar-May, Sep-Oct. Hilly, colourful, affordable, great pastéis. Mention Alfama, Belém, LX Factory, tram 28, Time Out Market. Portuguese food is nut-safe generally. Good vegetarian options in modern restaurants, traditional cuisine is meat-heavy but adapting. Use real Unsplash Lisbon photos.

- [ ] Create `src/content/destinations/amsterdam.md` — Amsterdam, Netherlands. Region: europe. Nut: 4, Veggie: 5. Flights ~£60, Hotel ~£150/night, 3-4 nights, Best: Apr-Jun, Sep. Canal city, cycling culture, world-class museums. Dutch cuisine is nut-safe. Incredible vegetarian scene — one of the best in Europe. Mention Jordaan, Rijksmuseum, Anne Frank House, Vondelpark, Albert Cuyp Market. Use real Unsplash Amsterdam photos.

- [ ] Create `src/content/destinations/copenhagen.md` — Copenhagen, Denmark. Region: europe. Nut: 5, Veggie: 4. Flights ~£80, Hotel ~£170/night, 3-4 nights, Best: May-Sep. Scandi cool, cycling city, incredible design. Nordic cuisine is very allergy-aware. Vegetarian options excellent in modern restaurants. Mention Nyhavn, Tivoli Gardens, Christiania, Torvehallerne, cycling culture. Use real Unsplash Copenhagen photos.

- [ ] Create `src/content/destinations/rome.md` — Rome, Italy. Region: europe. Nut: 3, Veggie: 4. Flights ~£70, Hotel ~£130/night, 5-7 nights, Best: Apr-Jun, Sep-Oct. Ancient history meets la dolce vita. Italian cuisine uses pine nuts and sometimes hazelnuts in pesto and desserts — need to ask about nuts specifically. Pasta and pizza are naturally vegetarian-friendly. Mention Colosseum, Trastevere, Vatican, Pantheon, gelato. Use real Unsplash Rome photos.

- [ ] Create `src/content/destinations/dubrovnik.md` — Dubrovnik, Croatia. Region: europe. Nut: 4, Veggie: 3. Flights ~£120, Hotel ~£140/night, 3-4 nights, Best: May-Jun, Sep-Oct. Stunning walled city on the Adriatic. Croatian cuisine is meat and seafood heavy — vegetarian options limited but improving. Generally nut-safe. Mention Old Town walls walk, Lokrum island, cable car, Game of Thrones locations. Use real Unsplash Dubrovnik photos.

- [ ] Create `src/content/destinations/edinburgh.md` — Edinburgh, Scotland. Region: europe. Nut: 5, Veggie: 5. Flights ~£50, Hotel ~£130/night, 3-4 nights, Best: May-Sep (especially Aug for Festival). Dramatic castle, Old Town, literary history. UK allergen laws — excellent nut allergy labelling. Superb vegetarian scene — David Bann, Henderson's. Mention Royal Mile, Arthur's Seat, Dean Village, Calton Hill. Use real Unsplash Edinburgh photos.

- [ ] Create `src/content/destinations/reykjavik.md` — Reykjavik, Iceland. Region: europe. Nut: 5, Veggie: 3. Flights ~£120, Hotel ~£200/night, 4-5 nights, Best: Jun-Aug (midnight sun) or Oct-Mar (northern lights). Otherworldly landscapes, geothermal pools. Very allergy-aware culture. Traditional Icelandic food is heavy on fish/lamb — limited veggie options outside Reykjavik. Mention Blue Lagoon, Golden Circle, Hallgrímskirkja, whale watching. Use real Unsplash Reykjavik photos.

- [ ] Create `src/content/destinations/paris.md` — Paris, France. Region: europe. Nut: 3, Veggie: 4. Flights ~£60, Hotel ~£160/night, 4-5 nights, Best: Apr-Jun, Sep-Oct. The classic. French patisserie uses nuts extensively (almonds, hazelnuts in almost everything) — need to be very careful with bakeries and desserts. Vegetarian scene has improved massively in recent years. Mention Le Marais, Montmartre, Canal Saint-Martin, Musée d'Orsay, food markets. Use real Unsplash Paris photos.

- [ ] Create `src/content/destinations/berlin.md` — Berlin, Germany. Region: europe. Nut: 4, Veggie: 5. Flights ~£60, Hotel ~£110/night, 4-5 nights, Best: May-Sep. Creative, alternative, affordable European capital. German cuisine is generally nut-safe (traditional dishes rarely use nuts). One of Europe's best cities for vegetarians and vegans — massive plant-based scene. Mention Kreuzberg, East Side Gallery, Tiergarten, Museum Island, flea markets. Use real Unsplash Berlin photos.

  After creating all 10 files, verify build: `npm run build`. Fix any schema validation errors.
  Commit: `git add -A && git commit -m "Add destination content: Europe batch 1 (Barcelona to Berlin)"`

### Phase 6: Destination Content — Europe (batch 2: 11-20)

- [ ] Create `src/content/destinations/vienna.md` — Vienna, Austria. Region: europe. Nut: 3, Veggie: 4. Flights ~£80, Hotel ~£130/night, 3-4 nights, Best: Apr-Jun, Sep-Oct. Imperial grandeur, coffee houses, classical music. Austrian baking uses a LOT of nuts (Linzer torte, marzipan, nut strudel) — be very careful with desserts and bakeries. Savoury dishes are safer. Good vegetarian options in modern Vienna. Mention Schönbrunn, Naschmarkt, MuseumsQuartier, Belvedere, coffee house culture. Use real Unsplash Vienna photos.

- [ ] Create `src/content/destinations/prague.md` — Prague, Czech Republic. Region: europe. Nut: 4, Veggie: 3. Flights ~£60, Hotel ~£90/night, 3-4 nights, Best: Apr-Jun, Sep-Oct. Fairy-tale architecture, cheap beer, incredible value. Czech cuisine is meat-heavy (pork, duck) — vegetarian options limited in traditional restaurants but modern places are catching up. Generally nut-safe. Mention Charles Bridge, Old Town Square, Prague Castle, Letná Park, craft beer. Use real Unsplash Prague photos.

- [ ] Create `src/content/destinations/athens.md` — Athens, Greece. Region: europe. Nut: 3, Veggie: 4. Flights ~£100, Hotel ~£100/night, 4-5 nights, Best: Apr-Jun, Sep-Oct. Ancient wonders and incredible food. Greek cuisine uses nuts in some dishes (baklava, pastries with walnuts/pistachios) — ask before ordering desserts. Excellent for vegetarians — feta, spanakopita, grilled veg, stuffed vine leaves. Mention Acropolis, Plaka, Monastiraki, National Garden, Exarcheia neighbourhood. Use real Unsplash Athens photos.

- [ ] Create `src/content/destinations/porto.md` — Porto, Portugal. Region: europe. Nut: 4, Veggie: 3. Flights ~£70, Hotel ~£90/night, 3-4 nights, Best: May-Sep. Port wine, azulejo tiles, riverside charm. Portuguese cuisine generally nut-safe. Traditional food is meat/fish heavy but Porto's restaurant scene is modernising with vegetarian options. Mention Ribeira, Livraria Lello, port wine cellars, Bolhão Market, São Bento station. Use real Unsplash Porto photos.

- [ ] Create `src/content/destinations/stockholm.md` — Stockholm, Sweden. Region: europe. Nut: 5, Veggie: 4. Flights ~£80, Hotel ~£170/night, 3-4 nights, Best: May-Sep. Beautiful archipelago city, Scandi design, ABBA Museum. Sweden has excellent allergen awareness — restaurants take allergies very seriously. Good vegetarian scene in Stockholm. Mention Gamla Stan, Djurgården, Fotografiska, Södermalm, archipelago boat trips. Use real Unsplash Stockholm photos.

- [ ] Create `src/content/destinations/budapest.md` — Budapest, Hungary. Region: europe. Nut: 3, Veggie: 3. Flights ~£70, Hotel ~£80/night, 3-4 nights, Best: Apr-Jun, Sep-Oct. Thermal baths, ruin bars, incredible value. Hungarian cuisine uses walnuts in desserts and some savoury dishes — check pastries. Traditional food is meat-heavy but Budapest has a growing vegetarian scene, especially in the Jewish Quarter. Mention ruin bars, Széchenyi Baths, Parliament, Fisherman's Bastion, Central Market Hall. Use real Unsplash Budapest photos.

- [ ] Create `src/content/destinations/bruges.md` — Bruges, Belgium. Region: europe. Nut: 3, Veggie: 3. Flights ~£60, Hotel ~£120/night, 2-3 nights, Best: Apr-Jun, Sep-Oct. Medieval fairytale, chocolate, beer, canals. Belgian chocolate and pralines are FULL of nuts — be extremely careful in chocolate shops. Savoury Belgian food (frites, waffles, stews) is generally nut-safe. Veggie options limited in traditional restaurants. Mention Markt square, Belfry, canal boat tour, chocolate shops, beer culture. Use real Unsplash Bruges photos.

- [ ] Create `src/content/destinations/lake-como.md` — Lake Como, Italy. Region: europe. Nut: 3, Veggie: 4. Flights ~£80 (to Milan), Hotel ~£160/night, 3-4 nights, Best: May-Sep. Glamorous lake surrounded by Alps. Same Italian nut cautions as Rome — pesto with pine nuts, hazelnuts in desserts. Beautiful setting for vegetarian Italian food. Mention Bellagio, Varenna, Villa Carlotta, ferry hopping between villages, Como town. Use real Unsplash Lake Como photos.

- [ ] Create `src/content/destinations/seville.md` — Seville, Spain. Region: europe. Nut: 4, Veggie: 4. Flights ~£90, Hotel ~£100/night, 3-4 nights, Best: Mar-May, Oct-Nov (summer is extremely hot). Flamenco, Moorish architecture, tapas capital. Spanish cuisine generally nut-safe — same guidance as Barcelona. Excellent vegetarian tapas. Mention Alcázar, Plaza de España, Triana, Metropol Parasol, tapas hopping in Santa Cruz. Use real Unsplash Seville photos.

- [ ] Create `src/content/destinations/marseille.md` — Marseille, France. Region: europe. Nut: 3, Veggie: 3. Flights ~£70, Hotel ~£110/night, 3-4 nights, Best: May-Sep. Gritty, authentic, Mediterranean port city. French cuisine nut cautions apply (especially in patisseries). Traditional Marseille food is fish-focused (bouillabaisse) but improving veggie scene in Le Panier area. Mention Calanques, Vieux Port, MuCEM, Notre-Dame de la Garde, Le Panier. Use real Unsplash Marseille photos.

  After creating all 10 files, verify build: `npm run build`. Fix any schema validation errors.
  Commit: `git add -A && git commit -m "Add destination content: Europe batch 2 (Vienna to Marseille)"`

### Phase 7: Destination Content — Americas

- [ ] Create `src/content/destinations/vancouver.md` — Vancouver, Canada. Region: americas. Nut: 5, Veggie: 5. Flights ~£450, Hotel ~£150/night, 5-7 nights, Best: Jun-Sep. Mountains meet ocean, incredible natural beauty. Canada has excellent allergen labelling laws — one of the safest countries for nut allergies. Superb vegetarian and vegan scene. Mention Stanley Park, Granville Island, Capilano Suspension Bridge, Gastown, day trip to Whistler. Use real Unsplash Vancouver photos.

- [ ] Create `src/content/destinations/montreal.md` — Montreal, Canada. Region: americas. Nut: 5, Veggie: 4. Flights ~£400, Hotel ~£120/night, 4-5 nights, Best: May-Oct (Jun-Aug warmest, fall colours in Sep-Oct). French-Canadian charm, food capital, bilingual culture. Same excellent Canadian allergen laws. Strong vegetarian scene in Mile End and Plateau. Mention Old Montreal, Mont Royal, Mile End, Jean-Talon Market, street art. Use real Unsplash Montreal photos.

- [ ] Create `src/content/destinations/new-york.md` — New York, USA. Region: americas. Nut: 4, Veggie: 5. Flights ~£350, Hotel ~£200/night, 5-7 nights, Best: Apr-Jun, Sep-Nov. The city that needs no introduction. US allergen laws are decent — restaurants must accommodate. Incredible vegetarian scene — possibly the best in the world. Mention Central Park, Brooklyn Bridge, High Line, Greenwich Village, Chelsea Market, Met Museum. Use real Unsplash New York photos.

- [ ] Create `src/content/destinations/mexico-city.md` — Mexico City, Mexico. Region: americas. Nut: 4, Veggie: 3. Flights ~£400, Hotel ~£80/night, 5-7 nights, Best: Mar-May, Oct-Nov. Massive, chaotic, incredible food, world-class museums. Mexican cuisine rarely uses nuts in savoury dishes (some moles do — always ask). Vegetarian harder in traditional settings but excellent in Roma and Condesa. Mention Frida Kahlo Museum, Chapultepec, Roma Norte, Coyoacán, Teotihuacán pyramids. Use real Unsplash Mexico City photos.

- [ ] Create `src/content/destinations/buenos-aires.md` — Buenos Aires, Argentina. Region: americas. Nut: 4, Veggie: 2. Flights ~£550, Hotel ~£70/night, 5-7 nights, Best: Oct-Dec, Mar-Apr. Tango, steak culture, European feel in South America. Argentine cuisine is very meat-centric — this is one of the hardest destinations for vegetarians. Nuts are not commonly used in savoury food though. Mention San Telmo market, La Boca, Recoleta, Palermo Soho, tango shows. Use real Unsplash Buenos Aires photos.

  After creating all 5 files, verify build: `npm run build`. Fix any schema validation errors.
  Commit: `git add -A && git commit -m "Add destination content: Americas (Vancouver to Buenos Aires)"`

### Phase 8: Destination Content — Asia, Oceania, Africa

- [ ] Create `src/content/destinations/tokyo.md` — Tokyo, Japan. Region: asia. Nut: 2, Veggie: 2. Flights ~£500, Hotel ~£130/night, 7-10 nights, Best: Mar-May (cherry blossom), Oct-Nov (autumn colours). Utterly unique, sensory overload, impeccable culture. **Nut allergy warning: Japanese cuisine uses peanuts, sesame, and tree nuts frequently. Allergen awareness is lower than in the UK — language barrier makes communicating allergies difficult. Carry a Japanese-language allergy card. Avoid: many sauces, some curries, mochi with nut fillings.** Vegetarian is also challenging — dashi (fish stock) is in almost everything, even "vegetable" dishes. Research shojin ryori (Buddhist temple cuisine) restaurants. Mention Shinjuku, Shibuya, Tsukiji Outer Market, Meiji Shrine, Akihabara, Harajuku. Use real Unsplash Tokyo photos.

- [ ] Create `src/content/destinations/kyoto.md` — Kyoto, Japan. Region: asia. Nut: 2, Veggie: 3. Flights ~£500 (fly to Osaka), Hotel ~£120/night, 4-5 nights, Best: Mar-May, Oct-Nov. Temples, gardens, geisha culture, traditional Japan. **Same nut allergy warnings as Tokyo — be very careful.** Slightly better for vegetarians than Tokyo due to strong Buddhist temple cuisine tradition (shojin ryori). Mention Fushimi Inari, Arashiyama bamboo, Kinkaku-ji, Gion district, Philosopher's Path. Use real Unsplash Kyoto photos.

- [ ] Create `src/content/destinations/seoul.md` — Seoul, South Korea. Region: asia. Nut: 2, Veggie: 2. Flights ~£450, Hotel ~£100/night, 5-7 nights, Best: Apr-May (cherry blossom), Sep-Nov (autumn). High-tech meets ancient palaces, incredible street food. **Nut allergy warning: Korean cuisine uses sesame oil/seeds extensively and peanuts appear in many sauces and side dishes. Allergen communication is difficult — carry a Korean-language allergy card.** Vegetarian is very challenging — even kimchi often contains fish sauce, and meat/seafood is in almost everything. Mention Gyeongbokgung, Bukchon Hanok Village, Myeongdong, Namsan Tower, DMZ tour. Use real Unsplash Seoul photos.

- [ ] Create `src/content/destinations/singapore.md` — Singapore. Region: asia. Nut: 2, Veggie: 4. Flights ~£450, Hotel ~£150/night, 4-5 nights, Best: Feb-Apr (driest). Ultra-modern city-state, melting pot cuisine, incredible gardens. **Nut allergy warning: Singapore's diverse cuisine (Chinese, Malay, Indian) uses nuts extensively — satay sauce is peanut-based, many curries contain ground nuts, Chinese dishes often contain cashews/peanuts. However, English is widely spoken so communicating allergies is easier than in Japan/Korea.** Good for vegetarians — Indian food district (Little India) is excellent. Mention Gardens by the Bay, Marina Bay Sands, hawker centres, Chinatown, Sentosa. Use real Unsplash Singapore photos.

- [ ] Create `src/content/destinations/melbourne.md` — Melbourne, Australia. Region: oceania. Nut: 5, Veggie: 5. Flights ~£600, Hotel ~£130/night, 5-7 nights, Best: Oct-Apr (Southern Hemisphere summer/autumn). Coffee capital, street art, multicultural food scene. Australia has some of the world's best allergen labelling — restaurants must declare allergens. Incredible vegetarian and vegan scene. Mention laneways, Great Ocean Road day trip, MCG, St Kilda, Queen Victoria Market. Use real Unsplash Melbourne photos.

- [ ] Create `src/content/destinations/queenstown.md` — Queenstown, New Zealand. Region: oceania. Nut: 5, Veggie: 3. Flights ~£650, Hotel ~£150/night, 5-7 nights, Best: Dec-Mar (summer) or Jun-Aug (skiing). Adventure capital surrounded by mountains and lakes. New Zealand has excellent allergen laws. Vegetarian options limited (it's a small town focused on adventure tourism) but improving. Mention bungee jumping, Milford Sound, Remarkables skiing, lake cruises, Arrowtown. Use real Unsplash Queenstown photos.

- [ ] Create `src/content/destinations/marrakech.md` — Marrakech, Morocco. Region: africa. Nut: 1, Veggie: 3. Flights ~£120, Hotel ~£70/night, 3-4 nights, Best: Mar-May, Oct-Nov. Sensory overload — souks, riads, Atlas Mountains. **Major nut allergy warning: Moroccan cuisine uses almonds, walnuts and pine nuts EXTENSIVELY — in tagines, couscous, pastilla, desserts, even salads. Nuts are ground into sauces and may not be visible. This is one of the highest-risk destinations for nut allergies. Communicate clearly and repeatedly.** Vegetarian is manageable — tagines can be made with vegetables, plenty of couscous and salad options. Mention Jemaa el-Fnaa, souks, Jardin Majorelle, Atlas Mountains day trip, riads. Use real Unsplash Marrakech photos.

  After creating all 7 files, verify build: `npm run build`. Fix any schema validation errors.
  Commit: `git add -A && git commit -m "Add destination content: Asia, Oceania, Africa"`

### Phase 9: Visual Verification & Polish

- [ ] Start the dev server (`npm run dev` in background). Use `agent-browser` to take screenshots of:
  1. Homepage at `http://localhost:4321/` — verify all 32 cards render, filter buttons visible, badges showing
  2. Homepage filtered to "Asia" — verify only 4 cards show
  3. A European destination detail page (e.g., `/destinations/barcelona`) — verify hero, quick facts, allergen badges, content sections, images
  4. An Asian destination with low allergen rating (e.g., `/destinations/tokyo`) — verify red allergen badges show correctly
  5. Mobile viewport (375px wide) — verify responsive layout works

  Review each screenshot. If anything looks broken, fix it before proceeding. Common issues to watch for:
  - Images not loading (bad URLs) — replace with working Unsplash URLs
  - Filter JS not working — check the inline script
  - Badge colours wrong — check the colour logic
  - Layout overflow on mobile — check Tailwind responsive classes
  - Typography too small or too large
  - Content sections not rendering from markdown

  Commit any fixes: `git add -A && git commit -m "Fix visual issues found during verification"`

- [ ] Review the content quality of at least 5 destination pages by reading them in the browser. Check for:
  - AI slop phrases ("hidden gem", "vibrant tapestry", "feast for the senses", "nestled", "bustling", "rich history and culture")
  - Generic content that could apply to any city
  - Inaccurate allergen information
  - Missing sections
  - Placeholder text that wasn't replaced
  Fix any issues found.
  Commit any fixes: `git add -A && git commit -m "Polish destination content quality"`

### Phase 10: QA Verification

- [ ] **QA: Setup** — Create screenshot directory: `mkdir -p Plans/qa-screenshots`. Ensure the dev server is running (`npm run dev` in background on port 4321). Log: "QA verification starting. Screenshots will be saved to Plans/qa-screenshots"

- [ ] **QA: Homepage loads with all 32 cards** — Open `http://localhost:4321/` in agent-browser. Wait for page to fully load. Count the number of destination cards visible on the page — there must be exactly 32. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/01-homepage-full.png`. Verify: all 32 cards are visible in the grid, each card has a photo that loads (no broken images), a title, country name, and allergen badges. The page should look professional with consistent spacing. If this fails: add a fix task to the plan with a description of the issue and re-add this verification task after the fix.

- [ ] **QA: Homepage card details** — With homepage still open, scroll to inspect several cards closely. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/02-homepage-cards-detail.png`. Verify: each card shows trip length, hotel cost (£X/night format), flight cost (£X return format), nut allergy badge, vegetarian badge. Badge colours are correct: green for 4-5, amber for 3, red for 1-2. Text is not truncated or overflowing card boundaries. If this fails: add a fix task with specifics of which element is broken.

- [ ] **QA: Region filter — Europe** — Click the "Europe" filter button. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/03-filter-europe.png`. Verify: only European destination cards are visible (20 cards). The "Europe" button appears selected/highlighted. Non-European cards are hidden. If this fails: add a fix task describing the filter issue.

- [ ] **QA: Region filter — Asia** — Click the "Asia" filter button. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/04-filter-asia.png`. Verify: only 4 Asian destination cards visible (Tokyo, Kyoto, Seoul, Singapore). All should have red nut allergy badges (rating 1-2). If this fails: add a fix task.

- [ ] **QA: Region filter — All** — Click "All" to reset. Verify all 32 cards reappear. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/05-filter-all-reset.png`. If this fails: add a fix task.

- [ ] **QA: Nut-safe filter** — Click the "Nut-safe only" toggle. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/06-nut-safe-filter.png`. Verify: only destinations with nut allergy rating 4 or 5 are shown. Asian destinations (rating 2) and Marrakech (rating 1) should be hidden. Cards with amber (3) badges should also be hidden. Count visible cards matches expected number. If this fails: add a fix task.

- [ ] **QA: Destination detail — safe destination (Edinburgh)** — Navigate to `/destinations/edinburgh`. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/07-edinburgh-hero.png`. Verify: hero image loads and fills the top section with gradient overlay, city name "Edinburgh" and "Scotland" overlaid on the image in white text. Scroll down. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/08-edinburgh-details.png`. Verify: quick facts bar shows best months, trip length (~£50 flights, ~£130/night hotel), both allergen badges are GREEN (5/5 for both). Content sections render with proper heading hierarchy (Things to Do, The Vibe, Things to See, Allergen & Dietary Detail). If this fails: add a fix task.

- [ ] **QA: Destination detail — risky destination (Marrakech)** — Navigate to `/destinations/marrakech`. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/09-marrakech-hero.png`. Verify: hero image loads. Scroll to allergen section. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/10-marrakech-allergens.png`. Verify: nut allergy badge is RED (1/5), vegetarian badge is AMBER (3/5). The allergen notes text is visible and warns about extensive nut use in Moroccan cuisine. If this fails: add a fix task.

- [ ] **QA: Destination detail — Asian destination (Tokyo)** — Navigate to `/destinations/tokyo`. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/11-tokyo-hero.png`. Scroll to allergen section. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/12-tokyo-allergens.png`. Verify: both nut allergy and vegetarian badges are RED (2/5 each). Content warns about nut prevalence in Japanese cuisine and difficulty communicating allergies. Mentions carrying a Japanese-language allergy card. If this fails: add a fix task.

- [ ] **QA: Destination detail — image gallery** — On any destination page (e.g., Barcelona), scroll to the bottom image gallery. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/13-image-gallery.png`. Verify: supporting images render in a 2-column grid, images load from Unsplash, each has alt text visible below. Images have rounded corners and consistent sizing. If this fails: add a fix task.

- [ ] **QA: Destination detail — navigation** — Verify "← Back to all destinations" link exists at both top and bottom of a destination detail page. Click the bottom link. Verify it navigates back to the homepage. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/14-back-navigation.png`. If this fails: add a fix task.

- [ ] **QA: Mobile responsive — homepage** — Resize the browser viewport to 375px width (mobile). Navigate to homepage. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/15-mobile-homepage.png`. Verify: cards display in a single column, no horizontal overflow, filter buttons wrap properly, text is readable, badges don't overlap or clip. If this fails: add a fix task describing the specific overflow or layout issue.

- [ ] **QA: Mobile responsive — detail page** — Navigate to `/destinations/barcelona` at 375px width. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/16-mobile-detail.png`. Verify: hero image scales properly, quick facts bar stacks vertically, content is readable, images scale within the viewport, no horizontal scrollbar. If this fails: add a fix task.

- [ ] **QA: Tablet responsive** — Resize viewport to 768px width. Navigate to homepage. Take screenshot: `agent-browser screenshot Plans/qa-screenshots/17-tablet-homepage.png`. Verify: cards display in 2-column grid, spacing is balanced, nothing overflows. If this fails: add a fix task.

- [ ] **QA: Content quality — no AI slop** — Read through the rendered content of at least 5 diverse destinations (Edinburgh, Tokyo, Barcelona, Marrakech, Vancouver). Check for banned phrases: "hidden gem", "vibrant tapestry", "feast for the senses", "nestled", "bustling", "rich tapestry", "mecca for", "paradise for", "a must-visit", "something for everyone". Also check: content is specific to each city (mentions actual places, streets, neighbourhoods), allergen info is practical and honest, not generic. If any slop is found: add a fix task listing the specific files and phrases to replace.

- [ ] **QA: Content completeness** — Verify all 32 destination markdown files exist and have all 4 body sections (Things to Do, The Vibe, Things to See, Allergen & Dietary Detail). Run: `for f in src/content/destinations/*.md; do echo "=== $f ==="; grep "^## " "$f"; done`. Verify each file has all 4 section headings. If any are missing: add a fix task listing the files and missing sections.

- [ ] **QA: Build output** — Run `npm run build`. Verify it completes without errors. Check that `dist/` directory contains HTML files for all 32 destinations plus the homepage. Run: `find dist -name "*.html" | wc -l` — should be at least 33 (1 homepage + 32 destination pages). Take note of build size. If build fails: add a fix task.

- [ ] **QA: All destination links work** — From the homepage, click on at least 5 destination cards from different regions and verify each navigates to the correct detail page with the right content. Take screenshot of one to prove: `agent-browser screenshot Plans/qa-screenshots/18-link-verification.png`. If any links are broken: add a fix task.

- [ ] **QA: Summary** — List all screenshots: `ls -la Plans/qa-screenshots/`. Print the full absolute path: "QA screenshots saved to: $(cd Plans/qa-screenshots && pwd)". Log pass/fail summary for each check to the progress file. Close the agent-browser session. Stop the dev server if still running.

### Phase 11: PR & Code Review

- [ ] Run `/pr` to create a pull request and trigger automated code review. Read the review comments from the output. For any issues scoring 50% or higher, add new checkbox tasks to this plan with sufficient detail to understand, reproduce, and fix each issue. These tasks will be picked up in subsequent iterations.

- [ ] After fixing all review issues, commit and push all fixes to the existing PR branch. Leave a comment on the PR summarising what review feedback was addressed.

### Phase 12: Cleanup

- [ ] Reflect on learnings from this implementation. Consider what gotchas were encountered, what was surprising, what would be useful to know for future work. If there are meaningful learnings:
  - Ensure `docs/learning/` directory exists
  - Write learnings to an appropriate file (e.g., `docs/learning/astro-static-sites.md`)
  - Commit the changes
  Log to progress file: "Reflected on learnings: [outcome]"
