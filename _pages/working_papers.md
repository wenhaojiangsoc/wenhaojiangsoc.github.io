---
layout: page
permalink: /working_papers/
title: Working Papers
description: Work in progress and papers under review, with replication files when available.
nav: true
nav_order: 3
---

<!-- _pages/working_papers.md -->

<style>
  /* Status is carried by the venue badge, so suppress the year heading and the
     year/note lines inside each entry. */
  .publications h2.bibliography,
  .publications .periodical {
    display: none;
  }

  /* In the Pipeline: one milestone track per project. Dots mark the stages,
     the line fills up to the current stage, and the current dot pulses.
     Projects and stages live in _data/pipeline.yml. */
  .pipeline {
    --pl-soft: color-mix(in srgb, var(--global-theme-color) 10%, transparent);
    --pl-ring: color-mix(in srgb, var(--global-theme-color) 28%, transparent);
    margin-top: 3rem;
    padding-top: 1.5rem;
    border-top: 1px solid var(--global-divider-color);
  }
  .pipeline h2 {
    font-size: 1.5rem;
    margin-bottom: 0.25rem;
  }
  .pipeline .lead {
    color: var(--global-text-color-light);
    margin-bottom: 1rem;
  }
  .pipeline .summary {
    display: flex;
    flex-wrap: wrap;
    gap: 0.4rem;
    margin-bottom: 1.5rem;
  }
  .pipeline .summary .chip {
    font-size: 0.8rem;
    padding: 0.15rem 0.7rem;
    border-radius: 999px;
    background: var(--pl-soft);
    color: var(--global-theme-color);
  }
  .pipeline .summary .chip b {
    font-weight: 700;
  }
  .pipeline .card-item {
    border: 1px solid var(--global-divider-color);
    border-radius: 12px;
    background: var(--global-card-bg-color);
    padding: 1rem 1.1rem 0.9rem;
    margin-bottom: 1rem;
  }
  .pipeline .head {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 0.75rem;
  }
  .pipeline .head .title {
    font-weight: bolder;
    line-height: 1.3;
  }
  .pipeline .head .authors {
    font-size: 0.85rem;
    color: var(--global-text-color-light);
    margin-top: 0.15rem;
  }
  .pipeline .head .step-pill {
    flex: none;
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.02em;
    padding: 0.2rem 0.6rem;
    border-radius: 999px;
    background: var(--pl-soft);
    color: var(--global-theme-color);
    white-space: nowrap;
    margin-top: 0.15rem;
  }
  .pipeline .track {
    display: flex;
    margin: 1rem 0 0.6rem;
  }
  .pipeline .step {
    flex: 1;
    position: relative;
    text-align: center;
  }
  .pipeline .step::before {
    content: "";
    position: absolute;
    top: 6px;
    left: -50%;
    width: 100%;
    height: 3px;
    background: var(--global-divider-color);
  }
  .pipeline .step:first-child::before {
    display: none;
  }
  .pipeline .step.on::before {
    background: var(--global-theme-color);
  }
  .pipeline .step .dot {
    position: relative;
    z-index: 1;
    display: block;
    width: 15px;
    height: 15px;
    margin: 0 auto;
    border-radius: 50%;
    background: var(--global-card-bg-color);
    border: 3px solid var(--global-divider-color);
    box-sizing: border-box;
  }
  .pipeline .step.on .dot {
    background: var(--global-theme-color);
    border-color: var(--global-theme-color);
  }
  .pipeline .step.cur .dot {
    box-shadow: 0 0 0 4px var(--pl-ring);
    animation: pipeline-pulse 2s ease-in-out infinite;
  }
  @keyframes pipeline-pulse {
    0%, 100% { box-shadow: 0 0 0 4px var(--pl-ring); }
    50% { box-shadow: 0 0 0 8px transparent; }
  }
  @media (prefers-reduced-motion: reduce) {
    .pipeline .step.cur .dot { animation: none; }
  }
  .pipeline .step .lbl {
    display: block;
    margin-top: 0.35rem;
    font-size: 0.68rem;
    line-height: 1.2;
    color: var(--global-text-color-light);
  }
  .pipeline .step.on .lbl {
    color: var(--global-text-color);
  }
  .pipeline .step.cur .lbl {
    color: var(--global-theme-color);
    font-weight: 700;
  }
  .pipeline .now {
    font-size: 0.85rem;
    color: var(--global-text-color-light);
    margin-top: 0.3rem;
  }
  .pipeline .now::before {
    content: "Now";
    font-size: 0.68rem;
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--global-theme-color);
    margin-right: 0.5rem;
  }
  @media (max-width: 576px) {
    .pipeline .head {
      flex-direction: column;
      gap: 0.4rem;
    }
    .pipeline .step:not(.cur) .lbl {
      visibility: hidden;
    }
  }
</style>

<div class="publications">

{% bibliography -f working_papers %}

</div>

{% assign stages = site.data.pipeline.stages %}
{% assign projects = site.data.pipeline.projects %}
{% assign n_stages = stages | size %}

<section class="pipeline">
  <h2>In the Pipeline</h2>
  <p class="lead">Where each project stands right now, from first idea to revise and resubmit.</p>

  <div class="summary">
    {% for s in stages reversed %}{% assign k = projects | where: "stage", s.key | size %}{% if k > 0 %}<span class="chip"><b>{{ k }}</b> {{ s.label | downcase }}</span>{% endif %}{% endfor %}
  </div>

  {% for p in projects %}
  {% assign cur = 0 %}{% assign cur_label = "" %}
  {% for s in stages %}{% if s.key == p.stage %}{% assign cur = forloop.index %}{% assign cur_label = s.label %}{% endif %}{% endfor %}
  <div class="card-item">
    <div class="head">
      <div>
        <div class="title">{{ p.title }}</div>
        <div class="authors">{{ p.authors }}</div>
      </div>
      <span class="step-pill">Stage {{ cur }} / {{ n_stages }}</span>
    </div>
    <div class="track" role="img" aria-label="Stage {{ cur }} of {{ n_stages }}: {{ cur_label }}">
      {% for s in stages %}<div class="step{% if forloop.index <= cur %} on{% endif %}{% if forloop.index == cur %} cur{% endif %}"><span class="dot"></span><span class="lbl">{{ s.label }}</span></div>{% endfor %}
    </div>
    <div class="now">{{ p.now }}</div>
  </div>
  {% endfor %}
</section>

<script>
  // Show abstracts by default; the Abs button still toggles them closed and open.
  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".publications .abstract.hidden").forEach(function (el) {
      el.classList.add("open");
    });
  });
</script>
