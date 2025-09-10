<script setup lang="ts">
import type { SubcategoryItemProps } from '@/Interface';
import camelCase from 'lodash/camelCase';
import { computed } from 'vue';
import { useI18n } from '@n8n/i18n';
import type { BaseTextKey } from '@n8n/i18n';

export interface Props {
	item: SubcategoryItemProps;
}

const props = defineProps<Props>();
const i18n = useI18n();
const subcategoryName = computed(() => camelCase(props.item.subcategory || props.item.title));

const displayTitle = computed(() => {
	const key = `nodeCreator.subcategoryNames.${subcategoryName.value}` as BaseTextKey;
	const translated = i18n.baseText(key);
	return translated === key ? props.item.title : translated;
});

const displayDescription = computed(() => {
	const key = `nodeCreator.subcategoryDescriptions.${subcategoryName.value}` as BaseTextKey;
	const translated = i18n.baseText(key);
	return translated === key ? props.item.description || '' : translated;
});
</script>

<template>
	<n8n-node-creator-node
		:class="$style.subCategory"
		:title="displayTitle"
		:is-trigger="false"
		:description="displayDescription"
		:show-action-arrow="true"
	>
		<template #icon>
			<n8n-node-icon
				type="icon"
				:name="item.icon"
				:circle="false"
				:show-tooltip="false"
				:use-updated-icons="true"
				v-bind="item.iconProps"
			/>
		</template>
	</n8n-node-creator-node>
</template>

<style lang="scss" module>
.subCategory {
	--action-arrow-color: var(--color-text-light);
	margin-left: 15px;
	margin-right: 12px;
}
</style>
