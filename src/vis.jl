using DataStructures
using Compose
import Compose: LCHab

## Visualise a program Stolen from compose.jl
function vistree(root::TypedSExpr;font_size=Compose.default_font_size)
    positions = Dict{Any, (Float64, Float64)}()
    level_count = Int[]
    max_level = 0

    # TODO: It would be nice if we can try to do a better job of positioning
    # nodes within their levels

    q = Queue((Any, Int))
    enqueue!(q, (root, 1))
    figs = compose!(context(), stroke("#333"), linewidth(0.5mm))
    figsize = 6mm
    while !isempty(q)
        node, level = dequeue!(q)

        if level > length(level_count)
            push!(level_count, 1)
        else
            level_count[level] += 1
        end
        max_level = max(max_level, level)

        # draw shit
        fig = context(level_count[level] - 1, level - 1)
        if isa(node, TypedSExpr)
            ctext = compose(context(order=-100),
                            text(0.55,0.5,"$(node.head.name)::$(valuetype(node))"),
                            fill("tomato"),
                            stroke("tomato"),linewidth(0.1mm),fontsize(font_size))
            compose!(fig,ctext)
            compose!(fig, circle(0.5, 0.5, figsize/2), fill(LCHab(92, 10, 77)))

            for child in node.args
                enqueue!(q, (child, level + 1))
            end
        elseif isa(node, Missing)
          ctext = compose(context(order=-100),
                          text(0.55,0.5,"$missing::$(valuetype(node))"),fill("tomato"),
                          stroke("tomato"),linewidth(0.1mm),fontsize(font_size))
            compose!(fig,ctext)
            # TODO: should be slightly different than Context...
            compose!(fig, circle(0.5, 0.5, figsize/2), fill(LCHab(92, 10, 77)))
        elseif isa(node, Var)
            ctext = compose(context(order=-100),
                            text(0.55,0.5,"Var:$(node.name)::$(valuetype(node))"),
                            fill("tomato"),
                          stroke("tomato"),linewidth(0.1mm),fontsize(font_size))
            compose!(fig,ctext)
            # TODO: what should the third color be?
            compose!(fig,
                polygon([(0.5cx - figsize/2, 0.5cy - figsize/2),
                         (0.5cx + figsize/2, 0.5cy - figsize/2),
                         (0.5, 0.5cy + figsize/2)]),
                fill(LCHab(68, 74, 29)))
        else
            ctext = compose(context(order=-100),
                          text(0.55,0.5,"$node::$(valuetype(node))"),
                          fill("tomato"),
                          stroke("tomato"),linewidth(0.1mm),fontsize(font_size))
            compose!(fig,ctext)
            compose!(fig,
                rectangle(0.5cx - figsize/2, 0.5cy - figsize/2, figsize, figsize),
                fill(LCHab(68, 74, 192)))
        end
        compose!(figs, fig)

        positions[node] = (level_count[level] - 0.5, level - 0.5)
    end

    # make a second traversal of the tree to draw lines between parents and
    # children
    lines_ctx = compose!(context(order=-1), stroke(LCHab(92, 10, 77)))
    enqueue!(q, (root, 1))
    while !isempty(q)
        node, level = dequeue!(q)
        if !isa(node, TypedSExpr)
            continue
        end
        pos = positions[node]

        for child in node.args
            childpos = positions[child]
            compose!(lines_ctx,
                     line([(pos[1], pos[2]), (childpos[1], childpos[2])]))
            enqueue!(q, (child, level + 1))
        end
    end

    return compose!(context(units=UnitBox(0, 0, maximum(level_count), max_level)),
                    (context(order=-2), rectangle(), fill("#333")),
                    lines_ctx, figs)
end

vistree(l::Lambda) = vistree(l.body)
