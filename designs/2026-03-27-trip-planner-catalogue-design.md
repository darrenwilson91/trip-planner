# Trip Planner Destination Catalogue — Design

## Overview

A static Astro site serving as a modern holiday brochure for Darren and Anthony. UK-based travellers. Darren has a nut allergy and is vegetarian — allergen and dietary safety is a first-class concern throughout the catalogue.

## Technical Stack

- **Framework:** Astro (latest v5.x) with Content Collections
- **Styling:** Tailwind CSS v4
- **Images:** Unsplash source URLs (free, no API key)
- **Hosting:** Static output, deployable anywhere
- **No JS framework** — pure static HTML, zero client-side JS

## Site Structure

```
/ (homepage)
  - Hero section with site title and tagline
  - Filter bar: region tabs (All / Europe / Americas / Asia / Oceania / Africa)
  - Filter: allergen safety toggle (show only "safe" destinations)
  - Destination card grid (responsive: 1 col mobile, 2 col tablet, 3 col desktop)

/destinations/[slug] (destination detail page)
  - Hero image with destination name overlay
  - Quick facts bar: trip length, best months, hotel cost, flight cost
  - Allergen & dietary safety badges (colour-coded)
  - Content sections: Summary, Things to Do, The Vibe, Things to See, Allergen & Dietary Detail
  - Supporting images gallery
  - Back to all destinations link
```

## Destination Data Model

Each destination is a `.md` file in `src/content/destinations/`:

**Frontmatter:**
```yaml
title: "Barcelona"
slug: "barcelona"
country: "Spain"
region: "europe"  # europe | americas | asia | oceania | africa
heroImage: "https://images.unsplash.com/photo-..."
heroImageAlt: "Aerial view of Barcelona with Sagrada Familia"
images:
  - url: "https://images.unsplash.com/photo-..."
    alt: "Sagrada Familia at sunset"
  - url: "https://images.unsplash.com/photo-..."
    alt: "La Boqueria market stalls"
summary: "A vibrant Mediterranean city where Gothic architecture meets golden beaches..."
bestMonths: [4, 5, 6, 9, 10]
tripLength: "4-5 nights"
hotelCostPerNight: 120
flightCostReturn: 80
nutAllergyRating: 4      # 1-5 scale
vegetarianRating: 5       # 1-5 scale
allergenNotes: "Spanish cuisine is generally nut-safe. Most tapas are nut-free..."
vegetarianNotes: "Excellent vegetarian scene, especially in the Eixample district..."
```

**Body markdown sections:**
```markdown
## Things to Do
...

## The Vibe
...

## Things to See
...

## Allergen & Dietary Detail
...
```

**Rating scale (both nut allergy and vegetarian):**
- 5 = Excellent — very safe/easy, strong awareness
- 4 = Good — generally safe/easy with minor caution
- 3 = Moderate — manageable with preparation and communication
- 2 = Challenging — requires significant vigilance
- 1 = Very Difficult — high risk, limited options

**Colour coding:**
- 4-5: Green badge
- 3: Amber badge
- 1-2: Red badge

## Design Aesthetic

- Magazine/brochure style — large photos, clean typography
- Font: System font stack (no external fonts to load)
- Colour palette: Warm neutrals with teal accent (#0d9488) for interactive elements
- Cards: Rounded corners, subtle shadow, hover lift effect
- Large hero images with text overlay using gradient scrim
- Generous whitespace, readable line lengths
- Allergen badges immediately visible on cards (not hidden)

## Destination List (32 destinations)

### Europe (20)
1. Barcelona, Spain
2. Lisbon, Portugal
3. Amsterdam, Netherlands
4. Copenhagen, Denmark
5. Rome, Italy
6. Dubrovnik, Croatia
7. Edinburgh, Scotland
8. Reykjavik, Iceland
9. Paris, France
10. Berlin, Germany
11. Vienna, Austria
12. Prague, Czech Republic
13. Athens, Greece
14. Porto, Portugal
15. Stockholm, Sweden
16. Budapest, Hungary
17. Bruges, Belgium
18. Lake Como, Italy
19. Seville, Spain
20. Marseille, France

### Americas (5)
21. Vancouver, Canada
22. Montreal, Canada
23. New York, USA
24. Mexico City, Mexico
25. Buenos Aires, Argentina

### Asia (4)
26. Tokyo, Japan
27. Kyoto, Japan
28. Seoul, South Korea
29. Singapore

### Oceania (2)
30. Melbourne, Australia
31. Queenstown, New Zealand

### Africa (1)
32. Marrakech, Morocco

## Content Guidelines

- Write as if recommending to a friend, not a travel brochure AI
- Be honest about allergen risks — don't sugarcoat Asian destination nut risks
- Include practical tips (e.g., "carry a nut allergy card in the local language")
- Costs in GBP, based on mid-range options (not budget, not luxury)
- Avoid superlatives and generic travel writing ("hidden gem", "bustling", "a feast for the senses")
- Each destination body should be 300-500 words across all sections
