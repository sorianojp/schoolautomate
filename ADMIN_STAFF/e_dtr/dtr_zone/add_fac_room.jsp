<%@ page language="java" import="utility.*, java.util.Vector, eDTR.DTRZoning, payroll.PRAjaxInterface" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
		
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Manage Restricted User List</title>
</head>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function pageAction(strInfoIndex, strAction) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to delete this record."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	
	document.form_.submit();
}

function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}

function loadRoomList() {
	var objCOA=document.getElementById("load_rooms");
	var strLoc = document.form_.loc_index[document.form_.loc_index.selectedIndex].value;
	var strType = document.form_.room_type[document.form_.room_type.selectedIndex].value;
	var strFilter = document.form_.room_filter.value;
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=604&loc_index="+strLoc+
							 "&r_type="+strType+"&sel_name=room_ref&show_all=1"+
							 "&room_filter="+strFilter;
	this.processRequest(strURL);
}

	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.page_action.value = "1";
		document.form_.submit();
	}
	
</script>
<%		
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iIndexOf  = 0;

	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./add_fac_room_print.jsp" />
	<% 
		return;}
			
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EDAILY TIME RECORD-DTR ZONING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EDAILY TIME RECORD"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-eDaily Time Record-DTR ZONING-Manage Faculty Room","add_fac_room.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	Vector vRetResult = null;	
	DTRZoning dtrz    = new DTRZoning();
	PRAjaxInterface prAjax = new PRAjaxInterface();
	
	String strLocIndex = WI.fillTextValue("loc_index");
	String[] astrRoom = null;
	Vector vSelected = new Vector();
	Vector vLocInfo    = null;
	if(strLocIndex.length() > 0) {
		request.setAttribute("loc_index", strLocIndex);
		vLocInfo = dtrz.createDTRZone(dbOP, request, 3);
	}
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(dtrz.operateOnFacRoomAssign(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = dtrz.getErrMsg();
		else	
			strErrMsg = dtrz.getErrMsg();
	}
	vRetResult = dtrz.operateOnFacRoomAssign(dbOP, request, 4);
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./add_fac_room.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    	<tr bgcolor="#A49A6A">
      		<td height="25" colspan="3" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
				  <strong>:::: MANAGE FACULTY ROOM RESTRICTION LIST ::::</strong></font></td>
    	</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%" colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
 	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		
		
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>eDTR Location</td>
		  <td><select name="loc_index" onchange="ReloadPage();">
            <%=dbOP.loadCombo("loc_index","loc_name", " from edtr_location where is_valid = 1", WI.fillTextValue("loc_index"),false)%>
          </select></td>
      </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Room Type </td>
		  <td><select name="room_type" onchange="loadRoomList();">
				<option value="">ALL</option>
        <%=dbOP.loadCombo("distinct room_type","room_type", " from e_room_detail where is_valid = 1 order by room_type", WI.fillTextValue("room_type"),false)%>
      </select></td>
	  </tr>
		<tr>
			<td width="3%" height="116">&nbsp;</td>
			<td width="16%">Room Number </td>
				<%
					astrRoom = request.getParameterValues("room_ref");
					if(astrRoom != null && astrRoom.length > 0){
 						for(int i = 0; i < astrRoom.length; i++){
							vSelected.addElement(astrRoom[i]);
						}
 					}
 				%>			
				<%if(vSelected == null || vSelected.size() == 0){
						strTemp2 = "selected";
					}else{
						strTemp2 = "";
						iIndexOf = vSelected.indexOf("0");
						if(iIndexOf != -1)
							strTemp2 = "selected";
					}
				%>
			<td width="81%">
			<label id="load_rooms">
			<select name="room_ref" size="6" multiple >
			<%
			if(WI.fillTextValue("room_type").length() ==0 ){%>
				<option value="0" <%=strTemp2%>>ALL</option>
			<%}%>				
					
					<%=prAjax.loadList(dbOP, request, "room_index","location, room_number", 
					" from e_room_detail where is_valid = 1 " +
					WI.getStrValue(WI.fillTextValue("room_type"), " and room_type = '","'","") + 
					WI.getStrValue(WI.fillTextValue("room_filter"), " and room_number like '","%'","") + 
					" and not exists (select * from EDTR_LOCATION_ROOM where loc_index = "+WI.fillTextValue("loc_index")+
					"   and EDTR_LOCATION_ROOM.room_index = e_room_detail.room_index) order by location, room_number", 
					"room_ref")%>
					

					<!--
					<%=dbOP.loadCombo("room_index","location, room_number", " from e_room_detail where is_valid = 1 " +
					WI.getStrValue(WI.fillTextValue("room_type"), " and room_type = '","'","") + 
					" and not exists (select * from EDTR_LOCATION_ROOM where loc_index = "+WI.fillTextValue("loc_index")+
					"   and EDTR_LOCATION_ROOM.room_index = e_room_detail.room_index) order by location, room_number", 
					WI.fillTextValue("room_ref"),false)%>
					-->					
			</select>
			</label>
			To select multiple room numbers, Hold CTRL key. </td>
    </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td><input type="text" name="room_filter" value="<%=WI.getStrValue(WI.fillTextValue("room_filter"))%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white';" size="8"/
			onkeyup="loadRoomList();">
		    room name filter </td>
	  </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
				<a href="javascript:pageAction('','1');"><img src="../../../images/save.gif" border="0" /></a><font size="1">Assign Room to the selected DTR. <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" width="71" height="23" border="0" /></a></font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print search results.</font></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr> 
		  	<td height="20" colspan="6" align="center" bgcolor="#B9B292" class="thinborder">
			    <strong>::: LOCATION ROOM LIST :::</strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Room Number </strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Room Location (Floor) </strong></td>
			<td width="33%" align="center" class="thinborder"><strong>Room Location (Building) </strong></td>
			<td width="13%" align="center" class="thinborder"><strong>List of Other DTR Terminal In case assigned to mutiple Location</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
		<%	int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i += 6, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 1), "All")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2), "All")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "All")%></td>
			<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "None")%></td>
			<td class="thinborder">
				<a href="javascript:pageAction('<%=vRetResult.elementAt(i)%>', '0');"><img src="../../../images/delete.gif" border="0" /></a>
			</td>
		</tr>
		<%}%>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" align="center">&nbsp;</td>
		</tr>
	</table>
<%}%>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="24"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index" />
	<input type="hidden" name="print_page" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>