import Map from './Map'
import LayersControl from './utilities/LayersControl'
import LayersButton from './utilities/LayersButton'

export default class RoutesMap extends Map
  constructor: (target) ->
    super(target)
    @area = []
    @seenStopIds = []
    @routes = {}

  addRoutes: (routes) ->
    routes.map (route) =>
      @addRoute route

  addRoute: (route)->	
    geoColPts = []	
    geoColLns = []	
    route.active = true	
    @routes[route.id] = route if route.id	
    stops = route.stop_points || route	
    geoColEdges = [	
      new ol.Feature(
        geometry: new ol.geom.Point(ol.proj.fromLonLat([parseFloat(stops[0].longitude), parseFloat(stops[0].latitude)]))	
      ),	
      new ol.Feature(
        geometry: new ol.geom.Point(ol.proj.fromLonLat([parseFloat(stops[stops.length - 1].longitude), parseFloat(stops[stops.length - 1].latitude)]))	
      )
    ]	

    prevStop = null	
    stops.forEach (stop, i) =>	
      if stop.longitude && stop.latitude	
        if prevStop	
          geoColLns.push new ol.Feature	
            geometry: new ol.geom.LineString([	
              ol.proj.fromLonLat([parseFloat(prevStop.longitude), parseFloat(prevStop.latitude)]),	
              ol.proj.fromLonLat([parseFloat(stop.longitude), parseFloat(stop.latitude)])	
            ])	
        prevStop = stop	

        geoColPts.push(new ol.Feature(
          geometry: new ol.geom.Point(ol.proj.fromLonLat([parseFloat(stop.longitude), parseFloat(stop.latitude)]))	
        ))	

        unless @seenStopIds.indexOf(stop.stoparea_id) > 0	
          @area.push [parseFloat(stop.longitude), parseFloat(stop.latitude)]	
          @seenStopIds.push stop.stoparea_id	

     vectorPtsLayer = new ol.layer.Vector(
      source: new ol.source.Vector(
        features: geoColPts	
      )	
      style: @defaultStyles()
      zIndex: 2	
    )	
    route.vectorPtsLayer = vectorPtsLayer if route.id	
    vectorEdgesLayer = new ol.layer.Vector(
      source: new ol.source.Vector(
        features: geoColEdges	
      )
      style: @edgeStyles()
      zIndex: 3	
    )	
    route.vectorEdgesLayer = vectorEdgesLayer if route.id	
    vectorLnsLayer = new ol.layer.Vector(
      source: new ol.source.Vector(
        features: geoColLns
      )
      style: [@lineStyle()],	
      zIndex: 1	
    )	
    route.vectorLnsLayer = vectorLnsLayer if route.id	
    @map.addLayer vectorPtsLayer	
    @map.addLayer vectorEdgesLayer	
    @map.addLayer vectorLnsLayer

  addLabels: (resourceName) ->
    menu = new LayersControl(@routes, this, resourceName: resourceName)
    @map.addControl(menu)
    @map.addControl(new LayersButton(menu: menu, resourceName: resourceName))

  fitZoom: ->	
    area = []	
    found = false	
    Object.keys(@routes).forEach (id)=>	
      route = @routes[id]	
      if route.active	
        found = true	
        route.stop_points.forEach (stop, i) =>	
          area.push [parseFloat(stop.longitude), parseFloat(stop.latitude)]	
    area = @area unless found	
    boundaries = ol.extent.applyTransform(	
      ol.extent.boundingExtent(area), ol.proj.getTransform('EPSG:4326', 'EPSG:3857')	
    )	
    @map.getView().fit boundaries, @map.getSize()	
    tooCloseToBounds = false	
    mapBoundaries = @map.getView().calculateExtent @map.getSize()	
    mapWidth = mapBoundaries[2] - mapBoundaries[0]	
    mapHeight = mapBoundaries[3] - mapBoundaries[1]	
    marginSize = 0.1	
    heightMargin = marginSize * mapHeight	
    widthMargin = marginSize * mapWidth	
    tooCloseToBounds = tooCloseToBounds || (boundaries[0] - mapBoundaries[0]) < widthMargin	
    tooCloseToBounds = tooCloseToBounds || (mapBoundaries[2] - boundaries[2]) < widthMargin	
    tooCloseToBounds = tooCloseToBounds || (boundaries[1] - mapBoundaries[1]) < heightMargin	
    tooCloseToBounds = tooCloseToBounds || (mapBoundaries[3] - boundaries[3]) < heightMargin	
    if tooCloseToBounds	
      @map.getView().setZoom(@map.getView().getZoom() - 1)