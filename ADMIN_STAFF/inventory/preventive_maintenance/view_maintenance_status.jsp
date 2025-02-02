<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	WebInterface WI = new WebInterface(request);	

	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

function ReloadPage(){
	document.form_.print_page.value = "";
	document.form_.view_details.value = "";
	document.form_.submit();
}

function ViewDetails(){
	document.form_.print_page.value = "";
	document.form_.view_details.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./view_maintenance_status_print.jsp"></jsp:forward>
	<%return;}
	
	//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-PREVENTIVE_MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Inventory -PREVENTIVE MAINTENANCE","view_maintenance_status.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}
	

String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName = {"Maintenance Date","Property No.","Item Name","College","Department"};
String[] astrSortByVal = {"maintenance_date","property_no","item_name","C_NAME","D_NAME"};


int iSearchResult = 0;
int iElemCount = 0;
Vector vRetResult = new Vector();

String[] strStatus = {"On-going","Complete"};
inventory.InvPreventiveMaintenance prevMain = new inventory.InvPreventiveMaintenance();

if(WI.fillTextValue("view_details").length() > 0){
	vRetResult = prevMain.generateMaintenanceStatus(dbOP, request);
	if(vRetResult == null)
		strErrMsg = prevMain.getErrMsg();
	else{
		iSearchResult = prevMain.getSearchCount();	
		iElemCount = prevMain.getElemCount();
	}
		
}

%>
<form name="form_" method="post" action="view_maintenance_status.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
	
	<tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: VIEW ASSET MAINTENANCE STATUS PAGE ::::</strong></font></div></td>
    </tr>
	
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
      <td height="27">&nbsp;</td>
      <td>Maintenance Date Range</td>
      <td colspan="3">
        <%strTemp = WI.fillTextValue("date_fr");%>
        <input name="date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("date_to");%>
        <input name="date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td height="25">Inventory Type</td>
        <td height="25" colspan="3">
		<select name="inventory_type" onChange="ReloadPage();">
			<option value=""></option>
			<%
			strTemp = WI.fillTextValue("inventory_type");
			if(strTemp.equals("0"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
	          <option value="0" <%=strErrMsg%>>Non-Supplies/Equipment</option>
			<%
			if(strTemp.equals("1"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="1" <%=strErrMsg%>>Supplies</option>  
			<%
			if(strTemp.equals("2"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="2" <%=strErrMsg%>>Chemical</option>  
			<%
			if(strTemp.equals("3"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="3" <%=strErrMsg%>>Computer/Parts</option>  
        </select>		</td>
        </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td height="25">Category</td>
        <td height="25" colspan="3">
		<select name="cat_index" onChange="ReloadPage();">
          <option value=""></option>
          <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					"where is_supply_cat = " + WI.getStrValue(WI.fillTextValue("inventory_type"),"0") + "order by inv_category", WI.fillTextValue("cat_index"), false)%> 
        </select>
		</td>
        </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td height="25">Classification</td>
        <td height="25" colspan="3">
		<select name="class_index" onChange="ReloadPage();">
        <option value=""></option>
        <%=dbOP.loadCombo("inv_class_index","classification"," from inv_preload_class " +
		  					"where inv_cat_index = " + WI.getStrValue(WI.fillTextValue("cat_index"),"0") + 
							" order by classification", WI.fillTextValue("class_index"), false)%>
      </select>
		</td>
        </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Property Number</td>
      <td width="35%" height="25"> <select name="property_no_select">
          <%=prevMain.constructGenericDropList(WI.fillTextValue("property_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="property_no" class="textbox" value="<%=WI.fillTextValue("property_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="18%">Maintenance Status : </td>
      <td width="26%">
	  <select name="maintenance_status">
	  <option value=""></option>
	  <%	  
	  
	  strTemp = WI.fillTextValue("maintenance_status");
	  for(int i =0 ; i < strStatus.length; i++){
	  	if(strTemp.equals(Integer.toString(i)))
	  		strErrMsg = "selected";
		else
			strErrMsg = "";
	  %>
	  <option  value="<%=i%>" <%=strErrMsg%>><%=strStatus[i]%></option>
	  <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25" colspan="3">
	  <select name="c_index" style="width:300px;" onChange="ReloadPage();">
	  	<option value=""></option>
		<%
		strTemp = " from college where is_del =0 order by c_name";
		%>
	  	<%=dbOP.loadCombo("c_index","c_name",strTemp, WI.fillTextValue("c_index"),false)%>
	  </select>	  </td>
      </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Department / Offices</td>
      <td height="25" colspan="3">
	  <select name="d_index" style="width:300px;">
	  	<option value=""></option>
		<%

		strTemp = " from DEPARTMENT where IS_DEL = 0 ";
		if(WI.fillTextValue("c_index").length() > 0)
			strTemp += " and c_index = "+WI.fillTextValue("c_index");
		strTemp += " order by d_name";
		%><%=dbOP.loadCombo("d_index", "d_name", strTemp, WI.fillTextValue("d_index"), false)%>
	  </select>	  </td>
      </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Building Name</td>
      <td><select name="building_name_select">
          <%=prevMain.constructGenericDropList(WI.fillTextValue("building_name_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="building_name" class="textbox" value="<%=WI.fillTextValue("building_name")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td>Room No</td>
      <td colspan="3">
	  <select name="room_no_select">
          <%=prevMain.constructGenericDropList(WI.fillTextValue("room_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="room_no" class="textbox" value="<%=WI.fillTextValue("room_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    
    
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4"><strong>Sort By</strong></td>
    </tr>
    <tr> 
      <td height="8">&nbsp;</td>
      <td width="23%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=prevMain.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=prevMain.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select></td>
      <td width="24%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=prevMain.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="26%"><select name="sort_by4">
          <option value="">N/A</option>
          <%=prevMain.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4"><a href="javascript:ViewDetails();"><img src="../../../images/form_proceed.gif" border="0" ></a> 
      </td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><Td align="right">
		Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 35;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 25; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	&nbsp; &nbsp;
	<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
	</Td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr><td align="center" height="25" colspan="10" class="thinborder">LIST OF MAINTENANCE STATUS</td></tr>
	<tr> 
		<td colspan="5" class="thinborder">
			<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(prevMain.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
		<td height="25" colspan="5" class="thinborderBOTTOM"> &nbsp;
		<%
			int iPageCount = 1;
			
			if(prevMain.defSearchSize > 0){
				iPageCount = iSearchResult/prevMain.defSearchSize;		
				if(iSearchResult % prevMain.defSearchSize > 0)
					++iPageCount;
			}
			
			strTemp = " - Showing("+prevMain.getDisplayRange()+")";
			if(iPageCount > 1){%> 
				<div align="right">Jump To page: 
				<select name="jumpto" onChange="document.form_.submit();">
				<%
					strTemp = WI.fillTextValue("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					int i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i = 1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
					}%>
				</select></div>
		<%}%> </td>
	</tr>
	<tr style="font-weight:bold">
	    <td align="center" width="10%" class="thinborder">Date</td>
	    <td align="center" width="9%" class="thinborder">Property No</td>
	    <td align="center" width="14%" class="thinborder">Item Name</td>
	    <td align="center" width="13%" class="thinborder">Office/Department</td>
	    <td align="center" width="11%" class="thinborder">Building/Room</td>
	    <td align="center" width="8%" height="25" class="thinborder">Category</td>
	    <td align="center" width="8%" class="thinborder">Classification</td>
	    <td align="center" width="7%" class="thinborder">Serial Number</td>
	    <td align="center" width="9%" class="thinborder">Product Number</td>
	    <td align="center" width="11%" class="thinborder">Status</td>
	</tr>
<%


for(int i = 0 ; i < vRetResult.size() ; i+=iElemCount){
%>
	<tr>
	    <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
	    <td class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
	    <td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+6));
		strErrMsg = WI.getStrValue(vRetResult.elementAt(i+8));
		if(strTemp.length() > 0 && strErrMsg.length() > 0)
			strTemp += " / ";
		strTemp += strErrMsg;
		%>
	    <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+10));
		strErrMsg = WI.getStrValue(vRetResult.elementAt(i+11));
		if(strTemp.length() > 0 && strErrMsg.length() > 0)
			strTemp += " / ";
		strTemp += strErrMsg;
		%>
	    <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
	    <td height="25" class="thinborder"><%=vRetResult.elementAt(i+3)%></td>
	    <td height="25" class="thinborder"><%=vRetResult.elementAt(i+4)%></td>
	    <td height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+12),"&nbsp;")%></td>
	    <td height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+13),"&nbsp;")%></td>
	    <td class="thinborder"><%=strStatus[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+14),"0"))]%></td>
	</tr>
<%}%>
</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td width="4%" height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>

  <input type="hidden" name="view_details" value="">  
  <input type="hidden" name="print_page" >
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
