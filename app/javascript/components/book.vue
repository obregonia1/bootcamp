<template lang="pug">
.col-xxxl-2.col-xxl-3.col-xl-4.col-lg-4.col-md-6.col-xs-12
  .card-books-item.a-card
    .card-books-item__body
      .card-books-item__inner
        .card-books-item__start
          a.card-books-item__cover-container(
            :href='book.pageUrl',
            target='_blank',
            rel='noopener')
            img.card-books-item__image(
              :title='book.title',
              :alt='book.title',
              :src='book.coverUrl')
        .card-books-item__end
          .card-books-item__rows
            .card-books-item__row
              h2.card-books-item__title
                span.a-badge.is-danger.is-sm(v-if='book.mustRead')
                  | 必読
                a.card-books-item__title-link(
                  :href='book.pageUrl',
                  target='_blank',
                  rel='noopener')
                  span.card-books-item__title-label
                    | {{ book.title }}
            .card-books-item__row
              p.card-books-item__price
                | {{ book.price.toLocaleString() }}円（税込）
            .card-books-item__row(v-if='book.description')
              .card-books-item__description
                .a-short-text(v-html='simpleFormat(book.description)')
    .card-books-item__practices
      .tag-links
        ul.tag-links__items
          li.tag-links__item(
            v-for='practice in book.practices',
            :key='practice.id')
            a.tag-links__item-link(:href='practice.practicePath')
              | {{ practice.title }}
    hr.a-border-tint
    footer.card-footer.is-only-mentor(v-if='isAdmin || isMentor')
      .card-main-actions
        ul.card-main-actions__items
          li.card-main-actions__item
            a.card-main-actions__action.a-button.is-sm.is-secondary.is-block(
              :href='book.editBookPath')
              | 編集
</template>
<script>
export default {
  props: {
    book: { type: Object, required: true },
    isAdmin: { type: Boolean, required: true },
    isMentor: { type: Boolean, required: true }
  },
  methods: {
    simpleFormat: function (str) {
      str = str.replace(/\r\n?/, '\n')
      str = $.trim(str)
      if (str.length > 0) {
        str = str.replace(/\n\n+/g, '</p><p>')
        str = str.replace(/\n/g, '<br />')
        str = '<p>' + str + '</p>'
      }
      return str
    }
  }
}
</script>
