// Component loader utility
const ComponentLoader = {
    async loadComponent(componentName, targetId) {
        try {
            const response = await fetch(`components/${componentName}.html`);
            const html = await response.text();
            document.getElementById(targetId).innerHTML = html;
        } catch (error) {
            console.error(`Failed to load component ${componentName}:`, error);
        }
    },

    async loadAllComponents() {
        const components = [
            { name: 'header', target: 'header-component' },
            { name: 'lookup-section', target: 'lookup-component' },
            { name: 'collection-section', target: 'collection-component' },
            { name: 'modal', target: 'modal-component' }
        ];

        await Promise.all(components.map(comp => 
            this.loadComponent(comp.name, comp.target)
        ));
    }
};
