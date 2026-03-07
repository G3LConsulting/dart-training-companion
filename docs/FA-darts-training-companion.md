# Functional Analysis — Darts Training Companion

**Document version:** 1.8
**Date:** 2026-03-07
**Status:** Draft
**Author:** Angelo

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-06 | Initial draft |
| 1.1 | 2026-03-06 | Added *Number Focus* game mode (FR-G-06 / FR-G-07 / FR-G-08); extended stats model with Number Focus metrics; added related badges |
| 1.2 | 2026-03-06 | Renamed *quality score* to *weighted accuracy* throughout |
| 1.3 | 2026-03-06 | Resolved all open questions; added MVP phasing section; added named drill methodologies to Module 3; removed guest mode from MVP |
| 1.4 | 2026-03-06 | Added Module 6 — Desktop Experience & Data Export (responsive layout, enhanced dashboard, session drill-down, Number Focus heat grid, CSV/Excel/JSON export); updated NFRs and MVP scope |
| 1.5 | 2026-03-06 | Full gap review: fixed 5 internal inconsistencies (Section 4 guest note, architecture diagram, FR-T-05 version label, FR-S-06 post-MVP note, duplicate separator); added OQ-07 to OQ-18 |
| 1.6 | 2026-03-06 | Resolved OQ-07 to OQ-18: added FR-P-06 (home screen), FR-G-09 (auto-save & resume), Cricket solo mode and Cricket stats model; updated FR-P-01 (auth), FR-P-03 (sync conflicts), FR-P-04 (delete recalculation), FR-L-01 (leaderboard min), FR-D-06 (export online-only), FR-S-04 (4-level heat grid) |
| 1.7 | 2026-03-07 | Final clarity pass: fixed FR-G-04 save contradiction (saving is automatic); added post-MVP callout blocks to FR-D-03 and FR-D-04; corrected Section 15.2 MVP scope table (added FR-P-06 and FR-G-09); added OQ-19 to OQ-23 |
| 1.8 | 2026-03-07 | Resolved OQ-19 to OQ-23: per-mode leaderboard metrics (Cricket → MPR, Number Focus excluded); Cricket solo drill is pure metric tracking; configurable fourth PB slot via Profile & Settings; week start day as user preference; account deletion flow added to FR-P-02 |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Scope](#2-scope)
3. [Target Audience & User Personas](#3-target-audience--user-personas)
4. [Assumptions & Constraints](#4-assumptions--constraints)
5. [Functional Modules Overview](#5-functional-modules-overview)
6. [Module 1 — Player Profiles & History](#6-module-1--player-profiles--history)
7. [Module 2 — Score Tracking & Game Modes](#7-module-2--score-tracking--game-modes)
8. [Module 3 — Training Exercises & Drills](#8-module-3--training-exercises--drills)
9. [Module 4 — Statistics & Progress Analytics](#9-module-4--statistics--progress-analytics)
10. [Module 5 — Leaderboards & Sharing](#10-module-5--leaderboards--sharing)
11. [Module 6 — Desktop Experience & Data Export](#11-module-6--desktop-experience--data-export)
12. [Non-Functional Requirements](#12-non-functional-requirements)
13. [Out of Scope](#13-out-of-scope)
14. [Open Questions](#14-open-questions)
15. [Release Planning — MVP vs. Post-MVP](#15-release-planning--mvp-vs-post-mvp)

---

## 1. Introduction

The **Darts Training Companion** is a Progressive Web App (PWA) designed to help recreational and hobby darts players improve their game through structured practice, detailed statistics, and motivating progress feedback. The app acts as a digital training partner: it tracks scores during play, guides players through targeted drills, records historical performance, and lets players see how they stack up against others via leaderboards.

The application is installable on any modern device (smartphone, tablet, desktop) directly from the browser, without requiring an app store, while still supporting offline usage for core features.

---

## 2. Scope

This functional analysis covers the **first production release (v1.0)** of the Darts Training Companion PWA. It describes the intended behaviour of the system from the perspective of the end user. Technical implementation decisions (architecture, frameworks, APIs) are deferred to the Technical Analysis.

The app covers six main functional areas:

- Player profiles and match history
- Score tracking across multiple game modes
- Structured training exercises and drills
- Statistics, analytics, and progress tracking
- Public leaderboards and social sharing
- Desktop-optimised dashboard and data export

The PWA uses a **single responsive codebase**. On mobile it is optimised for one-handed use at the oche. On desktop it unlocks a richer stats experience with larger charts, cross-mode comparisons, session drill-down, and data export capabilities.

---

## 3. Target Audience & User Personas

### 3.1 Primary Persona — The Hobby Player

| Attribute | Description |
|---|---|
| **Name** | The Hobby Player |
| **Age range** | 18 – 55 |
| **Skill level** | Beginner to intermediate |
| **Play context** | Home dartboard, local pub, occasional club night |
| **Motivation** | Wants to improve consistency, track personal bests, and have fun |
| **Tech comfort** | Comfortable with smartphones and web apps; not a power user |
| **Frustration** | No easy way to know if they're actually improving over time |

### 3.2 Secondary Persona — The Aspiring Club Player

| Attribute | Description |
|---|---|
| **Name** | The Aspiring Club Player |
| **Age range** | 20 – 45 |
| **Skill level** | Intermediate to advanced |
| **Play context** | Regular home practice, competes in local leagues |
| **Motivation** | Wants structured training, detailed stats, and benchmarking against peers |
| **Tech comfort** | High; uses apps regularly for sports tracking |
| **Frustration** | Existing apps are either too simple or too complex; no training structure |

---

## 4. Assumptions & Constraints

- The app targets **single-player use** at the oche; no real-time multiplayer or live opponent matching is in scope.
- Users **self-enter scores** manually on their device; no camera-based dart recognition is in scope for v1.0.
- An internet connection is required for leaderboard and sharing features; all other features must function **offline**.
- User accounts are required to persist data across devices and to participate in leaderboards.
- The app must be fully usable on a **smartphone held in one hand** while throwing darts, meaning large touch targets and minimal required input per turn.
- Data is stored **per user account**. Guest/anonymous sessions are out of scope for v1.0 (see OQ-01); registration is required to use the app.

---

## 5. Functional Modules Overview

```
┌─────────────────────────────────────────────────────────────┐
│                  Darts Training Companion                   │
├────────────────┬──────────────────┬─────────────────────────┤
│  Player        │  Game Modes &    │  Training Exercises &   │
│  Profiles &    │  Score Tracking  │  Drills (Post-MVP)      │
│  History       │                  │                         │
├────────────────┴──────────────────┴─────────────────────────┤
│         Statistics & Progress Analytics                     │
├─────────────────────────────────────────────────────────────┤
│         Leaderboards & Social Sharing (Post-MVP)            │
├─────────────────────────────────────────────────────────────┤
│         Desktop Experience & Data Export                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Module 1 — Player Profiles & History

### 6.1 Purpose

Allow a player to create and manage their personal profile, which acts as the anchor for all their game history, stats, and training data.

### 6.2 Functional Requirements

#### FR-P-01 — Account Registration

- A user registers using an **email address and password**. Third-party OAuth (e.g. Google) is not in scope for MVP (see OQ-17).
- After submitting the registration form, the user receives a **verification email**. The account is in a pending state until the email link is clicked; the user cannot access the app until verified.
- If the verification email is not received, the user can request a resend from the login screen.
- The user sets a **display name** (used in leaderboards and sharing) during registration.
- The user optionally selects a **dominant hand** (left/right) and **preferred game mode** during registration.
- A **password reset** flow is available from the login screen: the user enters their email address, receives a time-limited reset link, and can set a new password. The reset link expires after 1 hour.

#### FR-P-02 — Profile Management

- The user can edit their display name, avatar (upload or select from preset icons), and preferences at any time.
- The user can set a **target average** (e.g. "I want to reach a 3-dart average of 60") which is used in progress tracking.
- The user can set their **preferred week start day** (Monday or Sunday) in Profile & Settings. This determines the boundary used by the weekly summary card (FR-S-06) and the weekly session count on the home screen. Default: Monday.
- The user can configure the **fourth personal best slot** on the home screen (FR-P-06) by selecting one metric from the full list of tracked metrics (e.g. highest single turn, total sessions played, best MPR, best Cricket solo score). The setting is accessible from Profile & Settings under "Home screen preferences".
- The user can **delete their account** permanently from Profile & Settings:
  - A "Delete account" button opens a confirmation modal.
  - The user must type their email address to confirm before deletion proceeds.
  - Upon confirmation, the account is immediately deactivated (the user is logged out and cannot log back in).
  - All personal data (sessions, stats, personal bests, profile) is permanently purged from the server within **30 days**.
  - The user's display name is removed from all leaderboard entries immediately.
  - Any data files the user has already exported to their own device are not affected.

#### FR-P-03 — Multi-Device Sync

- A logged-in user's data is synced across devices automatically when online.
- When offline, data is stored locally and synced upon reconnection.
- If the same account has accumulated sessions on two devices while both were offline simultaneously, the app detects the conflict on sync and presents a **conflict resolution screen**:
  - The conflicting sessions are listed side by side with their date, game mode, and key stats.
  - The user can choose to **keep both** sessions (both are merged into the timeline), **keep one and discard the other**, or **keep neither**.
  - After resolving all conflicts, aggregate stats and personal bests are recalculated across the merged dataset.
  - Conflicts are resolved per session; unambiguous sessions (present on only one device) are merged automatically without prompting.

#### FR-P-04 — Match & Session History

- All completed games and training sessions are stored in the player's history.
- The history is browsable in a chronological list (most recent first).
- The user can view the full details of any past game or training session.
- The user can **delete** an individual entry from their history. Before deletion a confirmation prompt is shown: "Deleting this session will update your statistics. This cannot be undone."
- After a session is deleted, **all aggregate statistics and personal bests are fully recalculated** to reflect only the remaining sessions. The recalculation happens asynchronously in the background; the user sees a brief "Updating stats…" indicator.

#### FR-P-06 — Home Screen

The home screen is the landing page after login and the central navigation hub of the app. It contains four fixed sections, always visible without scrolling on a standard mobile screen:

- **Quick-start panel**: one large tappable card per MVP game mode (501, 301, Cricket, Number Focus). Tapping a card launches the game setup screen for that mode immediately.
- **Recent sessions strip**: the last 3–5 completed sessions shown as compact cards (date, game mode icon, key stat — e.g. "501 · 14-Mar · avg 58.3"). Tapping a session opens its detail (on mobile: a summary sheet; on desktop: the full drill-down view, FR-D-04 post-MVP).
- **Personal best highlights**: a compact row showing the player's current all-time bests for 3–4 key metrics (3-dart average, best Number Focus weighted accuracy, checkout %, and one user-configurable slot).
- **Weekly summary card**: the running summary for the current week (sessions played, average score vs. prior week). If no sessions have been played this week the card shows last week's summary with a "Start training" prompt.

On desktop the same four sections are arranged in a two-column grid in the main content area alongside the persistent sidebar.

---

#### FR-P-05 — Guest Mode *(Post-MVP)*

> **Note:** Guest mode is out of scope for v1.0. Registration and login are required to use the app. This requirement is retained in the FA for future consideration.

- A user can use the app without creating an account (guest mode).
- In guest mode, data is stored locally on the device only.
- The user is prompted to create an account to unlock sync, leaderboards, and sharing.
- A guest can convert their local session data to a full account at any time.

### 6.3 User Stories

- *As a new user, I want to create an account so that my progress is saved and accessible on any device.*
- *As a returning user, I want to see a summary of my last 5 sessions on my home screen so I can quickly review my recent form.*
- *As a user, I want to browse my full match history so I can track how my game has developed over time.*

---

## 7. Module 2 — Score Tracking & Game Modes

### 7.1 Purpose

Provide a smooth, in-session scoring interface for the most common recreational darts game formats, optimised for one-handed use on a mobile screen.

### 7.2 Supported Game Modes

| Game Mode | Description | Release |
|---|---|---|
| **501** | Standard countdown from 501; must finish on a double. Single player or local 2-player pass-and-play. | MVP |
| **301** | Same as 501 but starting from 301. | MVP |
| **Cricket** | Mark numbers 15–20 and bull three times each to close them; score points on open numbers. Supports **2-player pass-and-play** and **solo score drill** (reach a target score in fewest turns). | MVP |
| **Number Focus** | Dedicated single-number training. The player picks one target number and a dart count (default 50). Each dart is logged individually as Single, Double, Triple, or Miss. Stats (hit distribution and accuracy) are tracked per set and accumulated over time. | MVP |
| **Around the Clock** | Hit each number 1–20 (and bull) in sequence. | Post-MVP |
| **Halve It** | Hit target numbers per round or your score is halved; great for accuracy training. | Post-MVP |
| **Free Practice** | Open-ended session; player logs scores freely without win conditions. Used for warm-up and drill tracking. | Post-MVP |

### 7.3 Functional Requirements

#### FR-G-01 — Game Setup

- The user selects a game mode before starting a session.
- For **501 and 301**, the user selects the number of players (1 or 2 for local pass-and-play) and configurable rule options (e.g. double-in).
- For **Cricket**, the user selects one of two modes:
  - **2-player pass-and-play**: standard competitive Cricket; each player takes turns, closes numbers, and scores.
  - **Solo score drill**: single-player; the player closes all numbers (15–20 + bull) and aims to score as many points as possible. The session ends when all numbers are closed. The total score and turns taken are recorded and compared to the player's personal history. A **target score benchmark** (configurable, default 300) is displayed on screen during play as a personal reference point — there is no pass/fail outcome; the session always completes and is saved regardless of score reached.
- The user can name a second local player for pass-and-play games.
- For Number Focus, no opponent is applicable; setup is covered in FR-G-06.

#### FR-G-02 — In-Game Score Entry

- Scores are entered per **turn** (3 darts).
- The input method offers:
  - A **numeric keypad** (enter total score for the turn), OR
  - A **segment-by-segment entry** (enter each dart individually — score + multiplier).
- The user can toggle between input methods in settings.
- After each entry, the remaining score (for countdown games), current score, and round number are clearly displayed.
- The previous turn can be **undone** (one level of undo per active session).

#### FR-G-03 — Checkout Suggestions

- For 501/301 games, when a player is within checkout range (≤ 170), the app displays the optimal checkout combination for the remaining score (e.g. "T20, T19, D12").
- Checkout suggestions can be toggled on or off in settings.

#### FR-G-04 — Game Completion

- When a game ends (a player completes their checkout or all rounds are finished), a **post-game summary** is displayed.
- The summary shows: total turns, 3-dart average, highest turn, checkout scored (if applicable), and comparison to personal best.
- The completed game is **automatically saved to history** (see FR-P-04).
- From the post-game summary the user can: start a new game in the same mode, or return to the home screen.

#### FR-G-09 — Session Auto-Save & Resume

- During any active game session, the app **automatically saves the current state to local storage** after every scored turn (for 501/301/Cricket) or after every individual dart entry (for Number Focus).
- If the user navigates away from the app, closes the browser tab, or the device loses power, the in-progress session state is preserved in local storage.
- On the next app launch (after an interrupted session), the app detects the saved state and displays a **resume prompt**: "You have an unfinished [game mode] session from [time]. Resume or discard?"
  - **Resume**: the session is restored to the exact state at the last saved turn/dart. The user continues from where they left off.
  - **Discard**: the partial session is deleted. No data is saved to history. The user lands on the home screen.
- Only **one** in-progress session can be saved at a time, per device. Starting a new game while a saved session exists prompts the user to confirm discarding the previous one.
- Auto-saved state is stored locally only and does not sync across devices until the session is completed.

#### FR-G-05 — Bust & Rule Enforcement

- In 501/301, a bust (going below 1 or finishing on a non-double when double-out is required) is detected and the turn is automatically voided.
- The user is shown a clear "Bust!" notification.

#### FR-G-06 — Number Focus: Session Setup

- The user selects **Number Focus** as the game mode.
- The user selects the **target number** to train. Valid choices are: 1–20 and Bull.
- The user sets the **number of darts** for the session. The default is **50 darts**. The user may choose any value between 10 and 200 in increments of 10.
- The configured number of darts defines one **set**. A session always consists of exactly one set.
- The app displays a summary of the chosen configuration (target number + dart count) with a prominent "Start" button before the session begins.

#### FR-G-07 — Number Focus: In-Session Dart Entry

- Score is entered **per individual dart** (not per turn).
- For each dart thrown, the user taps one of four large buttons displayed on screen:
  - **Triple** — dart landed in the treble bed of the target number
  - **Double** — dart landed in the double bed of the target number
  - **Single** — dart landed in the single (large) bed of the target number
  - **Miss** — dart did not hit any bed of the target number
- Each tap is registered immediately and advances the dart counter by one.
- The screen continuously shows:
  - The **target number** (prominently)
  - The **dart counter**: darts thrown vs. total darts in the set (e.g. "17 / 50")
  - A running **hit breakdown**: how many Triples, Doubles, Singles, and Misses have been recorded so far in this set
  - The current **accuracy percentage** (any hit: Single + Double + Triple / darts thrown so far)
- The last dart entry can be **undone** with a single tap (one-level undo).
- The session ends automatically when the dart counter reaches the configured set size.

#### FR-G-08 — Number Focus: Session Results & Stored Stats

- When the set is complete, the app displays a **results screen** showing:
  - Target number and set size
  - Hit breakdown: Triple count, Double count, Single count, Miss count (shown both as absolute values and as percentages of total darts)
  - Overall **accuracy** (% of darts that hit any bed of the target number)
  - A **weighted accuracy** representing scoring efficiency: `(Triples × 3 + Doubles × 2 + Singles × 1) / (total darts × 3) × 100%` — this rewards treble hits over single hits
  - Comparison to the player's **personal best accuracy** and **personal best weighted accuracy** for this specific target number
- The following data is persisted per completed set:
  - Date and time
  - Target number
  - Set size (number of darts)
  - Triple count, Double count, Single count, Miss count
  - Accuracy %
  - Weighted accuracy %
- Personal bests are tracked separately per target number (e.g. best T20 accuracy, best Bull accuracy).
- The user may choose to: start a new set on the same number, change the target number, or return to the home screen.

### 7.4 User Stories

- *As a player, I want to track my 501 game on my phone while playing so I don't need a physical scoreboard.*
- *As a player, I want the app to tell me the best checkout route when I'm on a finish so I don't have to calculate it in my head.*
- *As a player, I want to undo my last score entry in case I mistyped.*
- *As a player, I want to throw 50 darts at T20 and instantly see how many trebles, doubles, singles, and misses I hit, so I have an honest picture of my T20 accuracy.*
- *As a player, I want to compare my T20 accuracy today against my personal best so I can see whether my targeting is improving over time.*
- *As a player, I want a colour-coded overview of all 21 numbers so I can immediately spot which numbers are weakest and decide what to train next.*

---

## 8. Module 3 — Training Exercises & Drills *(Post-MVP)*

> **Note:** This module is deferred to v2.0. The functional requirements below are fully specified for future implementation. The named drill library in section 8.2 is based on established coaching methodologies researched as part of OQ-04 resolution.

### 8.1 Purpose

Guide players through structured practice routines designed to target specific weaknesses and build consistent scoring. This is the core differentiator of the app versus a plain scoreboard.

### 8.2 Drill Categories & Named Routines

The built-in drill library will be organised by category and will include the following **established, named routines** drawn from recognised coaching methodologies, alongside original drills designed for the app.

#### Category: Doubles Practice

| Drill                 | Origin                               | How it works                                                                                                                                                                                                                                | Focus                                     |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| **Bob's 27**          | Bob Anderson (World Champion, 1980s) | Start with 27 points. Cycle through doubles D1–D20. Throw 3 darts at each double. Each hit adds the double value; missing all 3 darts subtracts one double from the running total. Goal: finish with the highest score possible.            | Doubles accuracy; high-pressure finishing |
| **Doubles Boomerang** | Tony David (BDO World Champion)      | Hit each double clockwise around the board starting at D1. One dart per double. A hit locks that double and advances to the next; a miss means returning to it on the next attempt. Goal: complete the circuit with the fewest total darts. | Sequential doubles; board coverage        |

#### Category: Checkout & Finishing

| Drill | Origin | How it works | Focus |
|---|---|---|---|
| **Checkout Challenge** | GoDartsPro | Start at checkout 21 with a 20-minute timer. Hit the finish within 3 darts → next target increases by 10. Miss → next target decreases by 1. Goal: reach the highest checkout value within the time limit. | Finishing accuracy; checkout calculation under pressure |

#### Category: All-Round Accuracy

| Drill | Origin | How it works | Focus |
|---|---|---|---|
| **Shanghai** | Traditional | Throw 3 darts at each number from 1 to 7 (or a configurable range). A "Shanghai" — hitting the single, double, and treble of the same number in one turn — scores a bonus. Goal: highest cumulative score. | Targeting precision across multiple bed types |
| **JDC Challenge** | Junior Darts Corporation | Three-part routine: (1) Shanghai drill on numbers 10–15, (2) one dart at each double D1–D20 + Bull, (3) Shanghai drill on numbers 15–20. Hitting a Shanghai (single + double + treble in one turn) scores a 100-point bonus. Used for player grading at JDC academies. | Multi-skill progression; doubles; treble accuracy |

#### Category: Grouping & Consistency

| Drill | Origin | How it works | Focus |
|---|---|---|---|
| **A1 Routine** | George Silberzahn | Hit numbers 20 down to 13 plus Bull, five times each (marks). Once a number has 5 marks it is "closed". Goal: close all numbers in the minimum number of rounds. Emphasises tight dart grouping in the same bed. | Dart grouping; precision; consistency |

### 8.3 Functional Requirements

#### FR-T-01 — Drill Library

- The app provides a built-in library of pre-defined drills, organised by category and difficulty (Beginner, Intermediate, Advanced).
- Each drill has a name, description, instructions, target score/metric, and estimated duration.
- The library is available offline.

#### FR-T-02 — Starting a Drill Session

- The user selects a drill from the library and starts a session.
- The app displays clear instructions for the drill before it begins.
- The user confirms readiness before the drill starts.

#### FR-T-03 — In-Drill Scoring & Guidance

- During a drill, the app guides the user step-by-step (e.g. "Now aim for T20 — throw 3 darts").
- The user inputs their result per step (hits, misses, score achieved).
- For drills with a pass/fail outcome per round (e.g. Halve It), the result is clearly shown.
- The app tracks cumulative performance (e.g. "7 out of 15 attempts hit the target") in real time.

#### FR-T-04 — Drill Completion & Results

- Upon completing a drill, the app shows a results screen with:
  - Score / hit rate achieved vs. target
  - Comparison to the user's personal best for that drill
  - A rating (e.g. star rating: 1–3 stars) based on performance thresholds
  - Option to repeat the drill or return to the library

#### FR-T-05 — Custom Drills (v2.0 — Basic)

- The user can create a simple custom drill by defining:
  - A name
  - A target (e.g. "Hit T20, 10 rounds, count total hits")
  - A goal (e.g. "Achieve 6 or more hits")
- Custom drills are saved to the user's profile and appear in the library under "My Drills".

#### FR-T-06 — Drill Recommendations

- Based on the player's recent statistics (e.g. low checkout percentage, weak on doubles), the app surfaces a "Recommended drill for today" on the home screen.

### 8.4 User Stories

- *As a player, I want to follow a structured doubles practice routine so I can improve my checkout percentage.*
- *As a player, I want to see how I performed on a drill compared to my personal best so I know if I'm improving.*
- *As a player, I want the app to suggest what to practise based on my weak spots so I don't waste time on areas I'm already good at.*

---

## 9. Module 4 — Statistics & Progress Analytics

### 9.1 Purpose

Give players meaningful, actionable insight into their performance over time, turning raw scores into a clear picture of where they stand and where to improve.

### 9.2 Tracked Metrics

#### 9.2.1 Game Statistics — 501 / 301

| Metric | Description |
|---|---|
| **3-dart average** | Average score per turn (3 darts) across all games |
| **First 9 average** | Average of the first 3 turns of a 501/301 game |
| **Highest turn** | Best single turn score |
| **Checkout percentage** | Ratio of successful checkout attempts to total checkout opportunities |
| **Most common checkout** | The finish the player hits most often |
| **Bust rate** | Percentage of turns that result in a bust |
| **100+ turns** | Count of turns scoring 100 or more |
| **140+ turns** | Count of turns scoring 140 or more |
| **180s** | Count of maximum scores |

#### 9.2.2 Game Statistics — Cricket

| Metric | Description |
|---|---|
| **Marks per Round (MPR)** | Average number of marks (hits on 15–20 or bull) scored per 3-dart turn. The standard Cricket skill benchmark; higher is better. |
| **Scoring turns %** | Percentage of turns in which the player scored points on an open number (i.e. the number was already closed on their side). Measures offensive efficiency. |
| **Closing speed per number** | Average number of darts required to close each individual number (15, 16, 17, 18, 19, 20, bull). Tracked per number so the player can see which beds take longest to close. |
| **Games played (Cricket)** | Total number of Cricket sessions completed |
| **Solo drill best score** | Highest score achieved in a solo Cricket score drill session |
| **Solo drill best turns** | Fewest turns taken to close all numbers in a solo drill session |

#### 9.2.3 Drill Statistics

| Metric | Description |
|---|---|
| **Hit rate per drill** | Percentage of successful hits over time for each drill |
| **Personal best per drill** | Best result ever achieved for a specific drill |
| **Drill sessions completed** | Total count of drill sessions |

#### 9.2.4 Number Focus Statistics

Tracked per target number (e.g. T20 stats are separate from Bull stats) and aggregated across all Number Focus sets.

| Metric | Description |
|---|---|
| **Triple %** | Percentage of darts landing in the treble bed of the target number, per set and over time |
| **Double %** | Percentage of darts landing in the double bed of the target number, per set and over time |
| **Single %** | Percentage of darts landing in the single (large) bed of the target number, per set and over time |
| **Miss %** | Percentage of darts that missed the target number entirely, per set and over time |
| **Accuracy %** | Overall hit rate: (Singles + Doubles + Triples) / total darts × 100%, per set and over time |
| **Weighted accuracy %** | Weighted scoring efficiency: (Triples × 3 + Doubles × 2 + Singles × 1) / (total darts × 3) × 100% — rewards hitting the treble over the single |
| **Best accuracy (per number)** | All-time best accuracy % for each specific target number |
| **Best weighted accuracy (per number)** | All-time best weighted accuracy % for each specific target number |
| **Total sets completed** | Total number of Number Focus sets completed, across all target numbers |
| **Total darts thrown (Number Focus)** | Cumulative darts thrown across all Number Focus sessions |

### 9.3 Functional Requirements

#### FR-S-01 — Stats Dashboard

- The user has access to a personal statistics dashboard.
- The dashboard shows key KPIs for the currently selected time range (Last 7 days / Last 30 days / Last 90 days / All time).
- Top-line KPIs (3-dart average, checkout %, total games played) are shown prominently.

#### FR-S-02 — Trend Charts

- The 3-dart average is displayed as a **line chart** over time, showing the trend.
- Checkout percentage is displayed as a **bar or line chart** over time.
- Charts are interactive: the user can tap/click a data point to see the exact value and date.

#### FR-S-03 — Personal Bests

- A dedicated "Personal Bests" section shows the all-time best values for each tracked metric.
- When a personal best is broken during a game, the user is notified with a congratulatory message.

#### FR-S-04 — Per-Game-Mode Breakdown

- Statistics are filterable by game mode (e.g. "Show only my 501 stats").
- For **Number Focus**, the stats view shows a **number selector** (1–20 + Bull) allowing the player to drill into the hit distribution and accuracy trend for a specific target number.
- A **Number Focus overview** shows all 21 target numbers in a grid, colour-coded by the player's best weighted accuracy using 4 levels: green (≥ 80%), yellow (50–79%), orange (25–49%), red (< 25% or no data yet). This is consistent with the desktop heat grid (FR-D-05).

#### FR-S-05 — Scoring Distribution

- A heatmap or bar chart showing which numbers the player scores on most frequently (based on dart-by-dart entry data, if segment-by-segment mode is used).
- This helps players visually identify their "favourite" bed and blind spots.

#### FR-S-06 — Weekly Summary

- At the end of each week (boundary determined by the user's preferred week start day set in FR-P-02), the app generates a "Weekly Summary" card showing: sessions played, average score, improvement vs. prior week, and the most-recommended drill for next week.
- This summary is accessible from the home screen and can be shared (see Module 5).

> **MVP note:** The "most-recommended drill" part of this summary is contingent on Module 3 (post-MVP). In v1.0 the weekly summary will show sessions, average, and improvement only; the drill recommendation slot will display once Module 3 is released.

### 9.4 User Stories

- *As a player, I want to see my 3-dart average trend over the last month so I know if I'm improving.*
- *As a player, I want to know my checkout percentage so I can decide whether to focus on finishes in training.*
- *As a player, I want to be notified when I set a new personal best so I feel rewarded for my progress.*

---

## 10. Module 5 — Leaderboards & Sharing

### 10.1 Purpose

Add a social layer that motivates players through friendly competition and lets them celebrate milestones with others, without requiring live multiplayer functionality.

### 10.2 Functional Requirements

#### FR-L-01 — Global Leaderboard

- Separate leaderboards exist for each competitive game mode. The ranking metric differs per mode:
  - **501 / 301**: ranked by **3-dart average** (rolling 30-day average)
  - **Cricket**: ranked by **MPR (Marks per Round)** (rolling 30-day average)
  - **Number Focus**: excluded from leaderboards — it is a training tool, not a competitive mode
- A player only appears on the leaderboard if they have played **at least 5 games** of that mode within the rolling 30-day window. Players below this threshold are not ranked but can still see their own rolling metric.
- The leaderboard is paginated and shows: rank, display name, avatar, and the relevant metric value.
- The user's own rank is always highlighted and visible (even if not in the top page).
- Leaderboard data refreshes when the device is online.

#### FR-L-02 — Leaderboard Opt-Out

- Participation in the global leaderboard is **opt-in**.
- The user can toggle their visibility on/off in their profile settings.
- When opted out, the user's data does not appear on any public leaderboard.

#### FR-L-03 — Friends Leaderboard

- A user can follow other players by their display name or a shareable profile link.
- A "Friends" leaderboard filters the global leaderboard to show only followed players plus the user themselves.

#### FR-L-04 — Sharing Stats & Achievements

- The user can share the following as a generated image card (suitable for social media):
  - Their weekly summary card
  - A personal best achievement (e.g. "I just hit a 3-dart average of 72.4 this week!")
  - A drill result (e.g. "I scored 9/10 on the T20 Accuracy drill!")
- Sharing opens the device's native share sheet (Web Share API).
- Shared cards include the app name/logo as branding.

#### FR-L-05 — Achievements & Badges

- The app awards **badges** for reaching milestones, for example:
  - First 180
  - 10 games completed
  - 3-dart average above 40 / 60 / 80 / 100
  - 7-day training streak
  - First 3-star drill result
  - **Number Focus — Sharp Eye**: achieve ≥ 80% accuracy on any target number in a set of 50
  - **Number Focus — Treble Hunter**: achieve ≥ 50% treble rate on any target number in a set of 50
  - **Number Focus — All-Round**: complete at least one set on every number from 1–20 and Bull
- Badges are visible on the user's profile.
- Earning a badge triggers an in-app notification and can be shared via FR-L-04.

### 10.3 User Stories

- *As a player, I want to see how my average compares to other players at my level so I have a benchmark to aim for.*
- *As a player, I want to share my weekly progress on social media so I can show friends how I'm improving.*
- *As a player, I want to earn badges for milestones so I stay motivated to keep practising.*

---

## 11. Module 6 — Desktop Experience & Data Export

### 11.1 Purpose

When the app is opened on a desktop or laptop browser (viewport width ≥ 1024 px), it transitions to a layout that makes full use of the available screen space. The desktop view is focused on **reviewing stats in depth** and **exporting data** — game entry still primarily happens on mobile. The same user account and data underpin both experiences; no separate login or application is needed.

### 11.2 Responsive Layout Principles

- Below **768 px** (mobile): single-column layout, large touch targets, minimal chrome. Optimised for one-handed use at the oche.
- **768–1023 px** (tablet): two-column layout where possible; touch-friendly but with more visible content.
- **≥ 1024 px** (desktop): multi-column dashboard layout, persistent left-hand navigation, expanded chart areas, data tables alongside charts.
- Layout transitions are handled purely through CSS responsive breakpoints within the single PWA codebase. No separate build or URL is required.

### 11.3 Functional Requirements

#### FR-D-01 — Desktop Navigation

- On desktop, a **persistent left-hand sidebar** replaces the mobile bottom navigation bar.
- The sidebar shows: Home / Dashboard, Game Modes, Statistics, (Drills — post-MVP), (Leaderboard — post-MVP), Profile & Settings.
- The active section is highlighted in the sidebar.
- The sidebar is collapsible to an icon-only rail to maximise chart space.

#### FR-D-02 — Enhanced Stats Dashboard (Desktop)

- On desktop, the statistics dashboard expands to a **multi-panel layout**:
  - A **KPI header strip** across the top showing key metrics for the selected time range (same as mobile FR-S-01, but always visible without scrolling).
  - A **primary chart area** (large, 2/3 of the screen width) showing the currently selected trend.
  - A **secondary panel** (1/3 of the screen width) showing supporting metrics or a summary table.
- The user can **overlay multiple metrics** on the primary chart (e.g. 3-dart average + checkout % on the same time axis) to spot correlations.
- Time range selection allows custom date ranges in addition to the preset options (Last 7 / 30 / 90 days / All time).
- Charts support **zoom and pan** along the time axis using mouse scroll or drag.

#### FR-D-03 — Side-by-Side Game Mode Comparison *(Post-MVP)*

> **Note:** This feature is deferred to v2.0. It is fully specified here for future implementation planning.


- A dedicated **"Compare"** view on desktop displays two or more game mode stat panels side by side.
- The user selects which game modes and which metrics to compare (e.g. 501 average vs Cricket score vs Number Focus accuracy over the same period).
- A shared time axis aligns all panels, making it easy to see whether improvement in one mode correlates with improvement in others.
- The comparison view can be exported directly (see FR-D-06).

#### FR-D-04 — Session Drill-Down (Replay View) *(Post-MVP)*

> **Note:** This feature is deferred to v2.0. It is fully specified here for future implementation planning.


- From the history or the stats dashboard, the user can click any completed game or Number Focus set to open a **session detail view**.
- For **501/301/Cricket** sessions, the detail view shows:
  - Turn-by-turn score table (turn number, score entered, running total / remaining score)
  - Per-turn bar chart highlighting high and low turns
  - Calculated metrics for that session (3-dart average, highest turn, bust turns if any)
- For **Number Focus** sets, the detail view shows:
  - Dart-by-dart result log (dart number, outcome: T/D/S/Miss)
  - Stacked bar chart of outcomes per group of 10 darts, showing how consistency evolved across the set
  - Session accuracy % and weighted accuracy % vs personal best at the time
- The session detail view is read-only; no editing of historical data is permitted.

#### FR-D-05 — Number Focus Heat Grid

- A full-board **accuracy heat grid** is displayed on desktop as a dedicated panel within the Number Focus stats view.
- The grid represents all 21 target numbers (1–20 + Bull) as cells, colour-coded by the player's best weighted accuracy for each number:
  - **Green** (≥ 80 %): strong — consistently hitting the target
  - **Yellow** (50–79 %): average — room for improvement
  - **Orange** (25–49 %): weak — needs deliberate practice
  - **Red** (< 25 % or no data): untrained / very weak
- Hovering over any cell shows a tooltip with: best accuracy, best weighted accuracy, total sets completed, and date of the most recent set for that number.
- Clicking a cell navigates directly to the Number Focus stats detail for that number, including the session history trend chart.
- On mobile, the heat grid is accessible as a scrollable list sorted by weighted accuracy (worst first) rather than as a spatial grid.

#### FR-D-06 — Data Export

The user can export their personal data from the **Profile & Settings** page and from within individual stats views. Data export **requires an active internet connection** to guarantee completeness across all devices. When the app is offline, all export buttons are disabled and a tooltip reads "Export requires an internet connection." This ensures exported files always reflect the full server-side dataset.

##### FR-D-06a — Export Scope Options

The user selects what to export before triggering the download:

| Scope | Contents |
|---|---|
| **All data** | Every game, Number Focus set, and profile metadata |
| **Game mode filter** | Only data for one selected game mode (e.g. 501 only) |
| **Date range filter** | Only data within a selected date range |
| **Current view** | Whatever is currently visible in the stats dashboard or comparison view |

##### FR-D-06b — CSV Export

- Exports a flat `.csv` file with one row per turn (for 501/301/Cricket) or one row per dart (for Number Focus).
- Column headers are human-readable (e.g. `Date`, `Game Mode`, `Turn`, `Score`, `Remaining`).
- Character encoding is **UTF-8 with BOM** for compatibility with Microsoft Excel on Windows.
- Large exports (> 10 000 rows) are generated asynchronously; the user receives a download prompt when ready.

##### FR-D-06c — Excel (.xlsx) Export

- Exports a formatted `.xlsx` workbook with **one sheet per game mode** present in the selected data.
- Each sheet includes:
  - A header row with column names (bold, frozen)
  - Data rows, one per turn or dart depending on mode
  - An auto-sized summary row at the bottom with aggregate values (totals, averages, best/worst)
- A dedicated **Summary sheet** is always present as the first sheet, showing top-level KPIs for each mode included in the export.
- Column widths are auto-fitted to content.

##### FR-D-06d — JSON Export

- Exports a structured `.json` file representing the player's full data graph.
- The JSON structure mirrors the internal data model closely to allow re-import or migration in a future app version.
- The export includes: profile metadata (display name, preferences — no password or email), all game sessions with full turn/dart detail, all Number Focus sets, and personal best records.
- The JSON is pretty-printed for human readability.

##### FR-D-06e — Export File Naming

- All exported files are named using the pattern: `darts-companion_{scope}_{YYYY-MM-DD}.{ext}`
- Example: `darts-companion_all-data_2026-03-06.xlsx`

### 11.4 User Stories

- *As a player sitting at my desk after a session, I want to open the app on my laptop and see a full-screen dashboard so I can analyse my stats properly without squinting at my phone.*
- *As a player, I want to see my 501 average and Cricket performance side by side so I can tell whether improving one game mode is helping the other.*
- *As a player, I want to click on last Tuesday's 501 session and see every single turn so I can understand where I went wrong.*
- *As a player, I want to see a colour-coded board showing which numbers I'm weakest at in Number Focus so I immediately know what to work on next.*
- *As a player, I want to export all my data to Excel so I can build my own charts or keep a personal archive.*
- *As a player, I want to export a JSON backup so I don't lose my data if I switch devices or the app changes.*

---

## 12. Non-Functional Requirements

### 12.1 Performance

- The app must be **interactive within 3 seconds** on a mid-range smartphone on a 4G connection on first load.
- Subsequent loads (with service worker cache) must be interactive within **1 second**.
- Score entry interactions must respond within **100 ms**.

### 12.2 Offline Support

- All features except leaderboards and sharing must be **fully functional offline**.
- Local data must sync automatically to the cloud upon reconnection without user intervention.
- The app must clearly indicate to the user when it is in offline mode.

### 12.3 Usability

- The app must be fully usable **one-handed on a 5–6 inch phone screen**.
- All primary actions (entering a score, starting a drill, viewing stats) must be reachable within **3 taps from the home screen**.
- Font sizes and touch targets must comply with WCAG 2.1 AA accessibility guidelines.
- The app must support both **light and dark mode**, following the device's system preference.
- On desktop (≥ 1024 px), all stats and export features must be reachable within **2 clicks from the main navigation sidebar**.
- Chart interactions (zoom, pan, tooltip, metric overlay toggles) must function correctly with both mouse and keyboard navigation.
- Data export operations must trigger a browser download within **5 seconds** for datasets up to 1 000 sessions; larger exports are processed asynchronously with a visible progress indicator.

### 12.4 Compatibility

- The app must function correctly on:
  - Chrome (Android & desktop) — latest 2 major versions
  - Safari (iOS 15+) — latest 2 major versions
  - Firefox (desktop) — latest 2 major versions
  - Edge (desktop) — latest 2 major versions
- The app must be **installable as a PWA** (meets installability criteria: service worker, manifest, HTTPS).

### 12.5 Data & Privacy

- User data must be stored securely; passwords must be hashed.
- The app must comply with GDPR: users can export their data and request account deletion.
- No personal data is shared with third parties beyond what is required for account authentication.
- Leaderboards display only the user's chosen display name, never their email.

### 12.6 Internationalisation

- The app is delivered in **English (en-GB)** for v1.0.
- Score formats and number separators must follow locale conventions.
- The architecture should support additional languages in future releases.

---

## 13. Out of Scope

The following items are explicitly **not** covered by this functional analysis or the v1.0 release:

- Real-time online multiplayer or live opponent matching
- Camera / computer vision based automatic dart detection
- Integration with hardware smart scoreboards or IoT dartboards
- Video recording or playback of throwing technique
- Coaching features for managing multiple players (coach portal)
- Tournament bracket management
- Monetisation (subscriptions, in-app purchases, ads)
- Native iOS / Android apps (app store distribution)
- Push notifications (browser notifications may be considered in a later version)

---

## 14. Open Questions

| #     | Question                                                                                                                                                                                                                        | Owner  | Status       | Decision                                                                                                                                                                                                           |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| OQ-01 | Should guest mode data be automatically migrated to a new account, or should the user be prompted to confirm the migration?                                                                                                     | Angelo | **Resolved** | Guest mode is **out of scope for MVP**. Registration is required to use the app in v1.0. Guest mode may be considered in a future release. FR-P-05 is post-MVP.                                                    |
| OQ-02 | What is the data retention policy for inactive accounts? Should user data be deleted after X months of inactivity?                                                                                                              | Angelo | **Deferred** | Not blocking for MVP. To be defined as a policy decision before public launch.                                                                                                                                     |
| OQ-03 | Should the 3-dart average on the leaderboard be based on a rolling 30-day window or a best-of-N games approach?                                                                                                                 | Angelo | **Resolved** | **Rolling 30-day average**. Reflects current form and motivates regular play.                                                                                                                                      |
| OQ-04 | Are there any specific drill routines from a well-known coaching methodology that should be included in the built-in library?                                                                                                   | Angelo | **Resolved** | Yes. See Module 3 — drill library now references established named routines: Bob's 27, JDC Challenge, A1 Routine, Checkout Challenge, Doubles Boomerang, and Shanghai. Drills module is post-MVP (see Section 14). |
| OQ-05 | Should segment-by-segment dart entry (individual dart logging) be the default input method, or should the simpler total-per-turn entry be the default?                                                                          | Angelo | **Resolved** | **Total per turn** is the default. Segment-by-segment entry remains available as an opt-in setting.                                                                                                                |
| OQ-06 | What is the target launch timeline and are there any feature priorities that should be phased across multiple releases?                                                                                                         | Angelo | **Resolved** | MVP = 501, 301, Cricket, Number Focus + Statistics. Module 3 (Drills) and Module 5 (Leaderboards & Sharing) are post-MVP. See Section 14.                                                                          |
| OQ-07 | What metrics should be tracked specifically for Cricket mode? | Angelo | **Resolved** | Track: **Marks per Round (MPR)**, **Scoring turns %**, and **Closing speed per number**. See updated section 9.2.1. |
| OQ-08 | Does Cricket support single-player (solo) mode? | Angelo | **Resolved** | Yes — **score-based solo drill**: player tries to reach a target score (default 300) in the fewest possible turns. See updated Cricket description and FR-G-01. |
| OQ-09 | What is the minimum number of games required before a player qualifies for the global leaderboard? | Angelo | **Resolved** | **Minimum 5 games** in the rolling 30-day window. See updated FR-L-01. |
| OQ-10 | Should account registration include email verification and password reset flows in MVP? | Angelo | **Resolved** | Yes to both. **Email verification** is required before the account is fully activated. **Password reset via email** is supported. Google OAuth is not in scope. See updated FR-P-01. |
| OQ-11 | What should the home screen show? | Angelo | **Resolved** | Four sections: (1) quick-start game mode buttons, (2) recent sessions (last 3–5), (3) personal best highlights, (4) weekly summary card. See new FR-P-06. |
| OQ-12 | Should there be a first-time user onboarding flow? | Angelo | **Resolved** | **No onboarding flow.** New users land directly on the home screen after registration. The UI must be self-explanatory. |
| OQ-13 | When a user deletes a historical session, what happens to stats? | Angelo | **Resolved** | **Full recalculation.** Deleting a session triggers recalculation of all aggregated stats and personal bests so they always reflect actual recorded games. See updated FR-P-04. |
| OQ-14 | What happens to an in-progress game if the user closes the browser or loses power? | Angelo | **Resolved** | **Auto-save and resume.** The in-progress session is saved locally after each scored turn/dart. On next open the user is offered to resume or discard. See new FR-G-09. |
| OQ-15 | Should data exports work offline? | Angelo | **Resolved** | **No — exports require an active internet connection** to guarantee completeness. Export options are greyed out with an offline indicator when the device has no connection. See updated FR-D-06. |
| OQ-16 | What is the sync conflict resolution strategy for simultaneous offline sessions on two devices? | Angelo | **Resolved** | **Flag conflicts for manual resolution.** When a conflict is detected on sync, the user is shown the conflicting sessions side-by-side and chooses which to keep (or keep both). See updated FR-P-03. |
| OQ-17 | Should Google (or other OAuth) sign-in be supported in MVP? | Angelo | **Resolved** | **No.** Email + password only for MVP. Third-party OAuth may be added post-MVP. See updated FR-P-01. |
| OQ-18 | How many colour levels should the Number Focus heat grid use? | Angelo | **Resolved** | **4 levels**: green (≥ 80%), yellow (50–79%), orange (25–49%), red (< 25% or no data). FR-S-04 updated to match FR-D-05. |
| OQ-19 | What ranking metric should the leaderboard use for Cricket and Number Focus? FR-L-01 currently specifies 3-dart average, which only applies to 501/301. Cricket's natural benchmark is MPR; Number Focus has no single agreed metric. | Angelo | **Resolved** | **501/301**: 3-dart average. **Cricket**: MPR (Marks per Round). **Number Focus**: excluded from leaderboards — it is a training mode, not a competitive one. See updated FR-L-01. |
| OQ-20 | Is the Cricket solo drill pass/fail against the target score, or purely metric tracking? FR-G-01 says the player "tries to reach a target score (default 300)" which implies a challenge outcome, but the stats model records score and turns without a pass/fail label. | Angelo | **Resolved** | **Pure metric tracking.** The session always completes and is saved. The target score (default 300) is a personal benchmark shown on screen for reference only — there is no pass/fail outcome. See updated FR-G-01. |
| OQ-21 | FR-P-06 references "one user-configurable slot" in the Personal Best highlights row on the home screen. What can the user configure here, and where is the setting located? Options: remove it and make the fourth metric fixed, or spec the setting. | Angelo | **Resolved** | **Keep configurable.** The user selects the fourth PB metric from the full list of tracked metrics via Profile & Settings → "Home screen preferences". See updated FR-P-02. |
| OQ-22 | FR-S-06 mentions a "configurable day" for the weekly summary boundary. Should the week start day follow the device locale automatically (e.g. Monday for EU, Sunday for US) with no user setting, or should it be a user preference in Profile & Settings? | Angelo | **Resolved** | **User preference in Profile & Settings.** Default: Monday. The setting determines the weekly boundary for the summary card and home screen weekly count. See updated FR-P-02 and FR-S-06. |
| OQ-23 | NFR 12.5 requires users to be able to request account deletion (GDPR). No FR currently covers this flow. Where does account deletion live (Profile & Settings), what confirmation is required, what is deleted server-side, and what is the timeline for purging data? | Angelo | **Resolved** | Account deletion lives in Profile & Settings. Confirmation requires typing the user's email address. Immediate logical deactivation; full server-side data purge within 30 days; leaderboard display name removed immediately. See updated FR-P-02. |

---

## 15. Release Planning — MVP vs. Post-MVP

### 15.1 Guiding Principle

The MVP targets a fast, focused release that delivers the core training loop — throw darts, track scores, see stats — for the four highest-value game modes. Social and drill features are valuable but non-essential for the initial launch and will follow in a subsequent release.

### 15.2 MVP (v1.0)

The following features are in scope for the initial release.

| Area | In scope for MVP |
|---|---|
| **Accounts** | Registration, login, profile management, multi-device sync, home screen (FR-P-01 to FR-P-04, FR-P-06). Guest mode excluded. |
| **Game Modes** | 501, 301, Cricket, Number Focus |
| **Score Tracking** | All FR-G-01 to FR-G-09 requirements for the four MVP game modes |
| **Statistics** | Full stats dashboard, trend charts, personal bests, per-mode breakdown, Number Focus analytics (FR-S-01 to FR-S-06) |
| **Desktop Experience** | Responsive layout, persistent sidebar navigation, enhanced charts with zoom/pan/overlay (FR-D-01, FR-D-02), Number Focus heat grid (FR-D-05), data export in CSV / Excel / JSON (FR-D-06) |
| **PWA** | Offline support, installability, light/dark mode |

### 15.3 Post-MVP (v2.0)

The following are deferred to the next release.

| Area                         | Deferred                                                                           |
| ---------------------------- | ---------------------------------------------------------------------------------- |
| **Game Modes**               | Around the Clock, Halve It, Free Practice                                          |
| **Desktop — advanced views** | Side-by-side game mode comparison (FR-D-03), session drill-down / replay (FR-D-04) |
| **Guest Mode**               | FR-P-05 — anonymous local sessions without an account                              |
| **Training Drills**          | Full Module 3 (drill library, custom drills, recommendations) — see Section 8      |
| **Leaderboards & Sharing**   | Full Module 5 (global leaderboard, friends, badges, sharing) — see Section 10      |
| **Data Retention Policy**    | OQ-02 — to be defined before or alongside v2.0 launch                              |

---

*End of Functional Analysis — Darts Training Companion v1.8*
