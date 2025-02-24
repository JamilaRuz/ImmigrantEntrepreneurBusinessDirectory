// Script to update company documents
const admin = require('firebase-admin');
const db = admin.firestore();

async function updateBookmarkSystem() {
  const companiesRef = db.collection('companies');
  const snapshot = await companiesRef.get();
  
  const batch = db.batch();
  
  snapshot.docs.forEach((doc) => {
    const companyRef = companiesRef.doc(doc.id);
    
    // Create update object
    const updateData = {
      // Remove isBookmarked field
      isBookmarked: admin.firestore.FieldValue.delete(),
      // Add bookmarkedBy array if it doesn't exist
      bookmarkedBy: []
    };
    
    batch.update(companyRef, updateData);
  });
  
  await batch.commit();
  console.log('Successfully updated all company documents');
} 