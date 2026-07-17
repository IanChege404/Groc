'use client';

import { useEffect, useState } from 'react';
import {
  collection,
  getDocs,
  query,
  QueryConstraint,
  onSnapshot,
  DocumentData,
  QuerySnapshot,
} from 'firebase/firestore';
import { db } from '@/lib/firebase-config';

interface UseFirestoreResult<T> {
  data: T[];
  loading: boolean;
  error: string | null;
}

export function useFirestore<T extends DocumentData = DocumentData>(
  collectionName: string,
  constraints: QueryConstraint[] = []
): UseFirestoreResult<T> {
  const [data, setData] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setLoading(true);
    setError(null);

    let q;
    if (constraints.length > 0) {
      q = query(collection(db, collectionName), ...constraints);
    } else {
      q = collection(db, collectionName);
    }

    const unsubscribe = onSnapshot(
      q,
      (snapshot: QuerySnapshot) => {
        const docs = snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        })) as T[];
        setData(docs);
        setLoading(false);
      },
      (err) => {
        setError(err.message);
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, [collectionName, constraints]);

  return { data, loading, error };
}

export async function fetchCollection<T extends DocumentData = DocumentData>(
  collectionName: string,
  constraints: QueryConstraint[] = []
): Promise<T[]> {
  const q =
    constraints.length > 0
      ? query(collection(db, collectionName), ...constraints)
      : collection(db, collectionName);

  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as T[];
}
