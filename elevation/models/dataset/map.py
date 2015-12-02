from ...app.proj import transformation, Projection, srid
from ....maps.styles import RegionalMap
import mapnik as M

mars_eqc = "+proj=eqc +lat_ts=0 +lat_0=0 +lon_0=180 +x_0=0 +y_0=0 +a=3396190 +b=3396190 +units=m +no_defs"
world = str(Projection.query.get(srid.world).proj4)

class Map(RegionalMap):
    def __init__(self,*args,**kwargs):
        RegionalMap.__init__(self,**kwargs)
        self.add_feature()

    def add_feature(self):
        s = M.Style()
        r = M.Rule()
        sym = M.LineSymbolizer()
        sym.stroke = M.Color('red')
        sym.comp_op = M.CompositeOp.soft_light
        r.symbols.append(sym)
        s.rules.append(r)

        pr = M.Rule()
        pr.filter = M.Filter("[mapnik::geometry_type]=polygon")
        psym = M.PolygonSymbolizer()
        psym.fill = M.Color('red')
        psym.fill_opacity = 0.2
        psym.comp_op = M.CompositeOp.soft_light
        pr.symbols.append(psym)
        s.rules.append(pr)

        self.append_style('Measurement',s)
        lyr = M.Layer('measurement',world)
        lyr.datasource = M.PostGIS(
            host='localhost',
            dbname='syrtis',
            table=str(q.statement),
            geometry_field="geometry")

        lyr.styles.append("Measurement")
        self.layers.append(lyr)

    def save(self,*args,**kwargs):
        M.render_to_file(self,*args, **kwargs)

    def as_string(self):
        img = M.Image(self.width, self.height)
        M.render(self, img)
        return img.tostring('png')
