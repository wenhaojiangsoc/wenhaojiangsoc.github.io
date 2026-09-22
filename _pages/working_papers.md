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
</style>

<div class="publications">

{% bibliography -f working_papers %}

</div>

<script>
  // Show abstracts by default; the Abs button still toggles them closed and open.
  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".publications .abstract.hidden").forEach(function (el) {
      el.classList.add("open");
    });
  });
</script>
