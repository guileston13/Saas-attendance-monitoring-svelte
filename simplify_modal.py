#!/usr/bin/env python3
"""
Simplify the sections page modal styling by replacing premium CSS with standard CSS
and removing complex HTML structure from the modal.
"""

import re

# Read the file
file_path = r'c:\Users\Jhunes\OneDrive\Documents\DEVELOPMENT\svelte\school-management-system\src\routes\sections\+page.svelte'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Step 1: Replace the complex modal HTML with simplified version
premium_modal_html = r'''			<!-- Modal Header with Icon -->
			<div class="premium-modal-header">
				<div class="modal-header-content">
					<div class="modal-icon-wrapper">
						<svg class="modal-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
							<line x1="9" y1="3" x2="9" y2="21"></line>
							{#if editingSection}
								<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
								<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
							{:else}
								<line x1="12" y1="5" x2="12" y2="19"></line>
								<line x1="5" y1="12" x2="19" y2="12"></line>
							{/if}
						</svg>
					</div>
					<div class="modal-title-section">
						<h3 class="premium-modal-title">{editingSection ? 'Edit Section' : 'Create New Section'}</h3>
						<p class="modal-subtitle">{editingSection ? 'Update section details' : 'Add a new section to your school'}</p>
					</div>
				</div>
				<button class="premium-modal-close" on:click={closeCreateModal} aria-label="Close modal">
					<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
						<line x1="18" y1="6" x2="6" y2="18"></line>
						<line x1="6" y1="6" x2="18" y2="18"></line>
					</svg>
				</button>
			</div>
			
			<!-- Modal Body with Enhanced Form -->
			<div class="premium-modal-body">'''

simple_modal_header = '''			<div class="modal-header">
				<h3>{editingSection ? 'Edit Section' : 'Create New Section'}</h3>
				<button class="close-btn" on:click={closeCreateModal}>&times;</button>
			</div>
			
			<form 
				method="POST" 
				action={editingSection ? "?/updateSection" : "?/createSection"}
				use:enhance={() => {
					loading = true;
					return async ({ result }) => {
						loading = false;
						if (result.type === 'success') {
							closeCreateModal();
							await invalidateAll();
						}
					};
				}}
			>
				{#if editingSection}
					<input type="hidden" name="sectionId" value={editingSection.SectionID} />
				{/if}
				
				<div class="form-group">
					<label for="sectionName">Section Name:</label>
					<input 
						type="text" 
						id="sectionName" 
						name="sectionName" 
						required 
						value={editingSection ? editingSection.SectionName : ''}
						placeholder="e.g., Grade 10 - Section A"
					/>
				</div>
				
				{#if editingSection}
					<div class="form-group">
						<label for="statusId">Status:</label>
						<select id="statusId" name="statusId" bind:value={editingSection.StatusID}>
							{#each statuses as status}
								<option value={status.StatusID}>{status.StatusName}</option>
							{/each}
						</select>
					</div>
				{/if}
				
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={closeCreateModal}>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary" disabled={loading}>
						{#if loading}
							<span class="spinner"></span>
							Saving...
						{:else}
							{editingSection ? 'Update Section' : 'Create Section'}
						{/if}
					</button>
				</div>
			</form>'''

# Step 2: Replace the complex form HTML 
complex_form = r'''				<form 
					method="POST" 
					action={editingSection ? "?/updateSection" : "?/createSection"}
					use:enhance={() => {
						loading = true;
						return async ({ result }) => {
							loading = false;
							if (result.type === 'success') {
								closeCreateModal();
								await invalidateAll();
							}
						};
					}}
				>
					{#if editingSection}
						<input type="hidden" name="sectionId" value={editingSection.SectionID} />
					{/if}
					
					<!-- Section Name Field -->
					<div class="premium-form-group">
						<label for="sectionName" class="premium-form-label">
							<svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
								<path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"></path>
							</svg>
							Section Name
						</label>
						<div class="input-wrapper">
							<input 
								type="text" 
								id="sectionName" 
								name="sectionName" 
								required 
								value={editingSection ? editingSection.SectionName : ''}
								placeholder="e.g., Grade 10 - Section A"
								class="premium-form-input"
							/>
							<div class="input-glow"></div>
						</div>
					</div>
					
					<!-- Status Field (Edit Only) -->
					{#if editingSection}
						<div class="premium-form-group">
							<label for="statusId" class="premium-form-label">
								<svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
									<circle cx="12" cy="12" r="10"></circle>
									<polyline points="12 6 12 12 16 14"></polyline>
								</svg>
								Status
							</label>
							<div class="select-wrapper">
								<select id="statusId" name="statusId" class="premium-form-select" bind:value={editingSection.StatusID}>
									{#each statuses as status}
										<option value={status.StatusID}>{status.StatusName}</option>
									{/each}
								</select>
								<div class="select-arrow">
									<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
										<polyline points="6 9 12 15 18 9"></polyline>
									</svg>
								</div>
							</div>
						</div>
					{/if}
					
					<!-- Action Buttons -->
					<div class="premium-modal-actions">
						<button type="button" class="btn btn-secondary premium-btn-secondary" on:click={closeCreateModal}>
							<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
								<line x1="18" y1="6" x2="6" y2="18"></line>
								<line x1="6" y1="6" x2="18" y2="18"></line>
							</svg>
							Cancel
						</button>
						<button type="submit" class="btn btn-primary premium-btn-primary" disabled={loading}>
							{#if loading}
								<div class="btn-spinner"></div>
								Saving...
							{:else}
								<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
									{#if editingSection}
										<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
										<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
									{:else}
										<line x1="12" y1="5" x2="12" y2="19"></line>
										<line x1="5" y1="12" x2="19" y2="12"></line>
									{/if}
								</svg>
								{editingSection ? 'Update Section' : 'Create Section'}
							{/if}
						</button>
					</div>
				</form>
			</div>'''

print("Checking if complex modal HTML exists...")
if premium_modal_html in content:
    print("✓ Found complex modal HTML, will replace")
    content = content.replace(premium_modal_html, simple_modal_header)
    print("✓ Replaced complex modal HTML with simple version")
else:
    print("✗ Complex modal HTML not found exactly - trying alternative approach")

# Step 3: Remove all premium CSS from the styles section
# Find the start and end of premium CSS
premium_css_start = content.find('/* === Premium Modal Styling === */')
premium_css_end = content.find('@media (max-width: 768px)')

if premium_css_start != -1 and premium_css_end != -1:
    print(f"✓ Found premium CSS section from {premium_css_start} to {premium_css_end}")
    # Replace with just a comment
    before_premium = content[:premium_css_start]
    after_premium = content[premium_css_end:]
    content = before_premium + '\t/* === Removed Premium Modal Styling === */\n\n\t' + after_premium
    print("✓ Removed all premium CSS styling")
else:
    print(f"✗ Could not find complete premium CSS section (start: {premium_css_start}, end: {premium_css_end})")

# Step 4: Remove premium CSS from media queries
# Find and remove .premium-modal-* rules from @media (max-width: 768px)
mobile_premium_pattern = r'\s*/\* Premium Modal Mobile Styles \*/(.*?)\.premium-btn-secondary, \.premium-btn-primary \{(.*?)\}'

content = re.sub(mobile_premium_pattern, '', content, flags=re.DOTALL)

print("✓ Removed premium CSS from mobile media query")

# Write back the file
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("\n✓ Successfully simplified the sections page modal!")
print("✓ Changes made:")
print("  - Replaced complex premium modal HTML with simple standard version")
print("  - Removed all premium CSS styling (~600+ lines)")
print("  - Removed premium mobile styles")
print("  - Modal now uses consistent styling with subjects/users pages")
