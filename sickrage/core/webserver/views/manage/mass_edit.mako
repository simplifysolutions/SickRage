<%inherit file="../layouts/main.mako"/>
<%!
    import sickrage
    from sickrage.core.common import SKIPPED, WANTED, UNAIRED, ARCHIVED, IGNORED, SNATCHED, SNATCHED_PROPER, SNATCHED_BEST, FAILED
    from sickrage.core.common import Quality, qualityPresets, qualityPresetStrings, statusStrings
    from sickrage.core.common import SD
%>

<%block name="content">
    <%
        if quality_value is not None:
            initial_quality = int(quality_value)
        else:
            initial_quality = SD

        anyQualities, bestQualities = Quality.splitQuality(initial_quality)
    %>

    <div id="config">

    <div id="ui-content">
        <form action="massEditSubmit" method="post">
            <input type="hidden" name="toEdit" value="${showList}" />

            <div id="ui-components">
                <ul>
                    <li><a href="#core-tab-pane1">${_('Main')}</a></li>
                </ul>

                <div id="core-tab-pane1">
                    <div class="row tab-pane">
                        <h3>${_('Main Settings')}</h3>

                        ==> <span style="text-decoration: underline;">${_('Changing any settings marked with')} (<span class="separator">*</span>) ${_('will force a refresh of the selected shows.')}</span><br>
                        <br>

                        <fieldset class="col-lg-9 col-md-8 col-sm-8 col-xs-12 tab-pane-list">

                        <div class="row field-pair">
                            <label for="shows">
                                <span class="component-title">${_('Selected Shows')}</span>
                                <span class="component-desc">
                                    % for curName in sorted(showNames):
                                    <span style="font-size: 14px;">${curName}</span><br>
                                    % endfor
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_root_dir_0">
                                <span class="component-title">${_('Root Directories')} (<span class="separator">*</span>)</span>
                                <span class="component-desc">
                                    <table class="sickrageTable" cellspacing="1" cellpadding="0" border="0">
                                        <thead>
                                            <tr>
                                                <th class="nowrap tablesorter-header">${_('Current')}</th>
                                                <th class="nowrap tablesorter-header">${_('New')}</th>
                                                <th class="nowrap tablesorter-header" style="width: 140px;">-</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        % for cur_dir in root_dir_list:
                                            <% cur_index = root_dir_list.index(cur_dir) %>
                                            <tr class="listing-default">
                                                <td align="center">${cur_dir}</td>
                                                <td align="center" id="display_new_root_dir_${cur_index}">${cur_dir}</td>
                                                <td>
                                                    <a href="#" class="btn edit_root_dir" class="edit_root_dir" id="edit_root_dir_${cur_index}">${_('Edit')}</a>
                                                    <a href="#" class="btn delete_root_dir" class="delete_root_dir" id="delete_root_dir_${cur_index}">${_('Delete')}</a>
                                                    <input type="hidden" name="orig_root_dir_${cur_index}" value="${cur_dir}" />
                                                    <input type="text" style="display: none" name="new_root_dir_${cur_index}" id="new_root_dir_${cur_index}" class="new_root_dir" value="${cur_dir}" />
                                                </td>
                                            </tr>
                                        % endfor
                                        </tbody>
                                    </table>
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="qualityPreset">
                                <span class="component-title">${_('Preferred Quality')}</span>
                                <span class="component-desc">
                                    <select id="qualityPreset" name="quality_preset" class="form-control form-control-inline input-sm">
                                        <option value="keep">&lt; Keep &gt;</option>
                                        <% selected = None %>
                                        <option value="0" ${('', 'selected')[quality_value is not None and quality_value not in qualityPresets]}>
                                            ${_('Custom')}
                                        </option>
                                        % for curPreset in sorted(qualityPresets):
                                            <option value="${curPreset}" ${('', 'selected')[quality_value == curPreset]}>${qualityPresetStrings[curPreset]}</option>
                                        % endfor
                                    </select>

                                    <div id="customQuality" style="padding-left: 0;">
                                        <div style="padding-right: 40px; text-align: left; float: left;">
                                            <h5>Allowed</h5>
                                            <% anyQualityList = filter(lambda x: x > Quality.NONE, Quality.qualityStrings) %>
                                            <select id="anyQualities" name="anyQualities" multiple="multiple" size="${len(anyQualityList)}" class="form-control form-control-inline input-sm">
                                                % for curQuality in sorted(anyQualityList):
                                                    <option value="${curQuality}" ${('', 'selected')[curQuality in anyQualities]}>${Quality.qualityStrings[curQuality]}</option>
                                                % endfor
                                            </select>
                                        </div>

                                        <div style="text-align: left; float: left;">
                                            <h5>Preferred</h5>
                                            <% bestQualityList = filter(lambda x: x >= Quality.SDTV, Quality.qualityStrings) %>
                                            <select id="bestQualities" name="bestQualities" multiple="multiple" size="${len(bestQualityList)}" class="form-control form-control-inline input-sm">
                                                % for curQuality in sorted(bestQualityList):
                                                    <option value="${curQuality}" ${('', 'selected')[curQuality in bestQualities]}>${Quality.qualityStrings[curQuality]}</option>
                                                % endfor
                                            </select>
                                        </div>
                                    </div>
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_skip_downloaded">
                                <span class="component-title">${_('Skip downloaded')}</span>
                                <span class="component-desc">
                                    <select id="edit_skip_downloaded" name="skip_downloaded" class="form-control form-control-inline input-sm">
                                        <option value="keep" ${('', 'selected')[skip_downloaded_value is None]}>&lt; ${_('Keep')} &gt;</option>
                                        <option value="enable" ${('', 'selected')[skip_downloaded_value == 1]}>${_('Yes')}</option>
                                        <option value="disable" ${('', 'selected')[skip_downloaded_value == 0]}>${_('No')}</option>
                                    </select><br>
                                    ${_('Skips updating quality of old/new downloaded episodes.')}
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_flatten_folders">
                                <span class="component-title">${_('Season folders')} (<span class="separator">*</span>)</span>
                                <span class="component-desc">
                                    <select id="" name="flatten_folders" class="form-control form-control-inline input-sm">
                                        <option value="keep" ${('', 'selected')[flatten_folders_value is None]}>&lt; ${_('Keep')} &gt;</option>
                                        <option value="enable" ${('', 'selected')[flatten_folders_value == 0]}>${_('Yes')}</option>
                                        <option value="disable" ${('', 'selected')[flatten_folders_value == 1]}>${_('No')}</option>
                                    </select><br>
                                    ${_('Group episodes by season folder (set to "No" to store in a single folder).')}
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_paused">
                                <span class="component-title">${_('Paused')}</span>
                                <span class="component-desc">
                                    <select id="edit_paused" name="paused" class="form-control form-control-inline input-sm">
                                        <option value="keep" ${('', 'selected')[paused_value is None]}>&lt; ${_('Keep')} &gt;</option>
                                        <option value="enable" ${('', 'selected')[paused_value == 1]}>${_('Yes')}</option>
                                        <option value="disable" ${('', 'selected')[paused_value == 0]}>${_('No')}</option>
                                    </select><br/>
                                    ${_('Pause these shows (SickRage will not download episodes).')}
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_default_ep_status">
                                <span class="component-title">${_('Default Episode Status')}</span>
                                <span class="component-desc">
                                    <select id="edit_default_ep_status" name="default_ep_status" class="form-control form-control-inline input-sm">
                                        <option value="keep">&lt; ${_('Keep')} &gt;</option>
                                        % for curStatus in [WANTED, SKIPPED, IGNORED]:
                                        <option value="${curStatus}" ${('', 'selected')[curStatus == default_ep_status_value]}>${statusStrings[curStatus]}</option>
                                        % endfor
                                    </select><br>
                                    ${_('This will set the status for future episodes.')}
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_scene">
                                <span class="component-title">${_('Scene Numbering')}</span>
                                <span class="component-desc">
                                    <select id="edit_scene" name="scene" class="form-control form-control-inline input-sm">
                                        <option value="keep" ${('', 'selected')[scene_value is None]}>&lt; ${_('Keep')} &gt;</option>
                                        <option value="enable" ${('', 'selected')[scene_value == 1]}>${_('Yes')}</option>
                                        <option value="disable" ${('', 'selected')[scene_value == 0]}>${_('No')}</option>
                                    </select><br>
                                    ${_('Search by scene numbering (set to "No" to search by indexer numbering).')}
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_anime">
                                <span class="component-title">${_('Anime')}</span>
                                <span class="component-desc">
                                    <select id="edit_anime" name="anime" class="form-control form-control-inline input-sm">
                                        <option value="keep" ${('', 'selected')[anime_value is None]}>&lt; ${_('Keep')} &gt;</option>
                                        <option value="enable" ${('', 'selected')[anime_value == 1]}>${_('Yes')}</option>
                                        <option value="disable" ${('', 'selected')[anime_value == 0]}>${_('No')}</option>
                                    </select><br>
                                    ${_('Set if these shows are Anime and episodes are released as Show.265 rather than Show.S02E03')}
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_sports">
                                <span class="component-title">${_('Sports')}</span>
                                <span class="component-desc">
                                    <select id="edit_sports" name="sports" class="form-control form-control-inline input-sm">
                                        <option value="keep" ${('', 'selected')[sports_value is None]}>&lt; ${_('Keep')} &gt;</option>
                                        <option value="enable" ${('', 'selected')[sports_value == 1]}>${_('Yes')}</option>
                                        <option value="disable" ${('', 'selected')[sports_value == 0]}>${_('No')}</option>
                                    </select><br>
                                    ${_('Set if these shows are sporting or MMA events released as Show.03.02.2010 rather than Show.S02E03.')}<br>
                                    <span style="color:red">${_('In case of an air date conflict between regular and special episodes, the later will be ignored.')}</span>
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_air_by_date">
                                <span class="component-title">${_('Air by date')}</span>
                                <span class="component-desc">
                                    <select id="edit_air_by_date" name="air_by_date" class="form-control form-control-inline input-sm">
                                        <option value="keep" ${('', 'selected')[air_by_date_value is None]}>&lt; ${_('Keep')} &gt;</option>
                                        <option value="enable" ${('', 'selected')[air_by_date_value == 1]}>${_('Yes')}</option>
                                        <option value="disable" ${('', 'selected')[air_by_date_value == 0]}>${_('No')}</option>
                                    </select><br>
                                    ${_('Set if these shows are released as Show.03.02.2010 rather than Show.S02E03.')}<br>
                                    <span style="color:red">${_('In case of an air date conflict between regular and special episodes, the later will be ignored.')}</span>
                                </span>
                            </label>
                        </div>

                        <div class="row field-pair">
                            <label for="edit_subtitles">
                                <span class="component-title">${_('Subtitles')}</span>
                                <span class="component-desc">
                                    <select id="edit_subtitles" name="subtitles" class="form-control form-control-inline input-sm">
                                        <option value="keep" ${('', 'selected')[subtitles_value is None]}>&lt; ${_('Keep')} &gt;</option>
                                        <option value="enable" ${('', 'selected')[subtitles_value == 1]}>${_('Yes')}</option>
                                        <option value="disable" ${('', 'selected')[subtitles_value == 0]}>${_('No')}</option>
                                    </select><br>
                                    ${_('Search for subtitles.')}
                                </span>
                            </label>
                        </div>

                        </fieldset>
                    </div>
                </div>

            </div>
            <input id="submit" type="submit" value="${_('Save Changes')}" class="btn pull-left config_submitter button">
        </form>
    </div>
</div>

</%block>
