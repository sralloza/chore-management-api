export const groupBy = <T, V, W>(
  iterable: T[],
  getter: (arg0: T) => V,
  modifier: (arg0: T) => W
) => {
  return iterable.reduce((group, element) => {
    const property: V = getter(element);
    group.set(property, group.get(property) ?? []);
    const newElement = modifier(element);
    group.get(property).push(newElement);
    return group;
  }, new Map() as Map<V, W[]>);
};
