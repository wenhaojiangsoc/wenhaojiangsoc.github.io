---
layout: page
permalink: /blog/
title: Resources
description: Guides and notes for students and collaborators.
nav: true
nav_order: 7
---

{% include resources_style.liquid %}

{% assign groups = site.posts | group_by_exp: "post", "post.categories | first" %}

<div class="resources">
{% for group in groups %}
  <h2 class="group">{{ group.name | capitalize }}</h2>
  {% for post in group.items %}
  {% assign read_time = post.content | number_of_words | divided_by: 180 | plus: 1 %}
  <div class="entry">
    <a class="title" href="{{ post.url | relative_url }}">{{ post.title }}</a>
    <div class="desc">{{ post.description }}</div>
    <div class="meta">{{ post.date | date: "%B %-d, %Y" }} &middot; {{ read_time }} min read</div>
  </div>
  {% endfor %}
{% endfor %}
</div>
