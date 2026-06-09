import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { society, societyLocation } from '../../core';

export const initializeSocietyForm = (formBuilder: FormBuilder) =>
  formBuilder.group({
    societyName: ['', Validators.required],
    societyDescription: ['', Validators.required],
    societyContactEmail: ['', [Validators.required, Validators.email]],
    societyContactPhone: ['', Validators.required],
    societyWebsiteUrl: ['', Validators.required],
    societyCompletionDate: [{ value: '', disabled: true }, Validators.required],
    societyBuilder: ['', Validators.required],
    societyPromoter: ['', Validators.required],
    societyLocationAddress: ['', Validators.required],
    societyLocationCity: ['', Validators.required],
    societyLocationState: ['', Validators.required],
    societyLocationPostalCode: ['', Validators.required],
    societyLocationDistrict: ['', Validators.required],
    societyLocationCountry: ['', Validators.required],
  });

export const convertToSocietyFromForm = (
  formGroup: FormGroup,
): { society: society; societyLocation: societyLocation } =>
  ({
    society: {
      name: formGroup.get('societyName')?.value,
      description: formGroup.get('societyDescription')?.value,
      contactEmail: formGroup.get('societyContactEmail')?.value,
      contactPhone: formGroup.get('societyContactPhone')?.value,
      websiteUrl: formGroup.get('societyWebsiteUrl')?.value,
      completionDate: new Date(formGroup.get('societyCompletionDate')?.value),
      builder: formGroup.get('societyBuilder')?.value,
      promoter: formGroup.get('societyPromoter')?.value,
      status: 'active',
    },
    societyLocation: {
      address: formGroup.get('societyLocationAddress')?.value,
      city: formGroup.get('societyLocationCity')?.value,
      state: formGroup.get('societyLocationState')?.value,
      postalCode: formGroup.get('societyLocationPostalCode')?.value,
      district: formGroup.get('societyLocationDistrict')?.value,
      country: formGroup.get('societyLocationCountry')?.value,
      status: 'active',
    },
  }) as { society: society; societyLocation: societyLocation };

export const convertToSocietyCreateRpcFromObject = (
  society: society,
  societyLocation: societyLocation,
): Record<string, any> => ({
  p_name: society.name,
  p_description: society.description,
  p_contact_email: society.contactEmail,
  p_contact_phone: society.contactPhone,
  p_website_url: society.websiteUrl,
  p_completion_date: society.completionDate.toISOString(),
  p_builder: society.builder,
  p_promoter: society.promoter,
  p_society_status: society.status,
  p_address: societyLocation.address,
  p_city: societyLocation.city,
  p_state: societyLocation.state,
  p_postal_code: societyLocation.postalCode,
  p_country: societyLocation.country,
  p_district: societyLocation.district,
  p_location_status: societyLocation.status,
});

export const convertApiResponseToSociety = (data: any[]) =>
  data?.map(
    (val) =>
      ({
        name: val['name'],
        description: val['description'],
        builder: val['builder'],
        promoter: val['promoter'],
      }) as society,
  );
