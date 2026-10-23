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

  /* In the Pipeline: entries reuse the bibliography layout, with the stage as
     the badge and a stage track under the authors. Projects and stages live in
     _data/pipeline.yml. */
  .publications.pipeline h2.bibliography {
    display: block;
  }
  .publications.pipeline .periodical {
    display: block;
  }
  .publications.pipeline .abbr abbr {
    white-space: normal;
  }
  .pipeline .track {
    display: flex;
    margin: 0.6rem 0 0.3rem;
  }
  .pipeline .step {
    flex: 1;
    position: relative;
    text-align: center;
  }
  .pipeline .step::before {
    content: "";
    position: absolute;
    top: 4px;
    left: -50%;
    width: 100%;
    height: 1px;
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
    display: block;
    width: 9px;
    height: 9px;
    margin: 0 auto;
    border-radius: 50%;
    background: var(--global-bg-color);
    border: 1px solid var(--global-divider-color);
  }
  .pipeline .step.on .dot {
    background: var(--global-theme-color);
    border-color: var(--global-theme-color);
  }
  .pipeline .step .lbl {
    display: block;
    text-align: center;
    text-align-last: center;
    margin-top: 0.25rem;
    font-size: 0.7rem;
    line-height: 1.2;
    color: var(--global-text-color-light);
  }
  .pipeline .step.cur .lbl {
    color: var(--global-theme-color);
  }
  @media (max-width: 576px) {
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

<div class="publications pipeline">
  <h2 class="bibliography">In the Pipeline</h2>
  <ol class="bibliography">
  {% for p in projects %}
  {% assign cur = 0 %}{% assign cur_label = "" %}
  {% for s in stages %}{% if s.key == p.stage %}{% assign cur = forloop.index %}{% assign cur_label = s.label %}{% endif %}{% endfor %}
  <li><div class="row">
    <div class="col col-sm-2 abbr"><abbr class="badge rounded w-100">{{ cur_label }}</abbr></div>
    <div class="col-sm-8">
      <div class="title">{{ p.title }}</div>
      <div class="author">{{ p.authors }}</div>
      <div class="track" role="img" aria-label="Stage {{ cur }} of {{ stages | size }}: {{ cur_label }}">
        {% for s in stages %}<div class="step{% if forloop.index <= cur %} on{% endif %}{% if forloop.index == cur %} cur{% endif %}"><span class="dot"></span><span class="lbl">{{ s.label }}</span></div>{% endfor %}
      </div>
      <div class="periodical"><em>{{ p.now }}</em></div>
    </div>
  </div></li>
  {% endfor %}
  </ol>
</div>

<script>
  // Show abstracts by default; the Abs button still toggles them closed and open.
  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".publications .abstract.hidden").forEach(function (el) {
      el.classList.add("open");
    });
  });
</script>
