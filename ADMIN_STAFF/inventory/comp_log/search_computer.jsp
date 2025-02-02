<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;


	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function ViewDetails(strInfoIndex)
{
	var pgLoc = "./view_property_dtls.jsp?info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SearchNow()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
<%
if(WI.fillTextValue("opner_info").length() > 0){	
%>
function CopyPropNum(strPropNum)
{	
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strPropNum;
	window.opener.focus();
	<%if(strFormName != null){
		if(strFormName.equals("form_")){
	%>
	window.opener.document.<%=strFormName%>.submit();	
	<%}
	}%>
	self.close();
}
<%}%>
</script>

<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY LOG","search_computer.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strQuery = "";
	String strProcessor = null;

	int iSearchResult = 0;

	InventorySearch InvSearch = new InventorySearch();

	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Property Number","Processor Type","College","Department","Building","Room"};
	String[] astrSortByVal     = {"prop_num","PROCESSOR_TYPE","c_code","d_name",
															 "bldg_name","room_number"};

	if(WI.fillTextValue("executeSearch").compareTo("1") == 0){
	vRetResult = InvSearch.searchComputer(dbOP, request);
	if(vRetResult == null)
		strErrMsg = InvSearch.getErrMsg();
	else	
		iSearchResult = InvSearch.getSearchCount();
}
	
%>

<body bgcolor="#D2AE72">
<form action="./search_computer.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          COMPUTER MAINTENANCE: PROPERTY SEARCH PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="4" height="20"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="4"> <%strTemp = WI.fillTextValue("c_index");%> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department</td>
      <td colspan="4"><%strTemp2 = WI.fillTextValue("d_index");%> <select name="d_index">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="">All</option>
          <%} if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
		else strTemp = " and c_index = " +  strTemp;%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Building</td>
      <td colspan="4"><%strTemp = WI.fillTextValue("bldg_index");%> <select name="bldg_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Room</td>
      <td colspan="4"><%strTemp2 = WI.fillTextValue("room_idx");%> <select name="room_idx">
          <option value="">N/A</option>
          <%if (strTemp.length()>0){
				strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
				" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Loc Description</td>
      <td><select name="loc_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("loc_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td colspan="3"><input type="text" name="loc" value="<%=WI.fillTextValue("loc")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Property Number</td>
      <td width="10%"><select name="prop_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("prop_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td width="26%"><input type="text" name="prop" value="<%=WI.fillTextValue("prop")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%">&nbsp;</td>
      <td width="30%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Serial Number</td>
      <td><select name="serial_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("serial_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="serial" value="<%=WI.fillTextValue("serial")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Product Number</td>
      <td><select name="prod_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("prod_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="prod" value="<%=WI.fillTextValue("prod")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Processor Type</td>
      <td colspan="2"> 
      <%strProcessor = WI.fillTextValue("processor_type");%>
        <select name="processor_type">
          <option value="" selected>Select Type</option>
          <%if (WI.getStrValue(strProcessor,"").equals("0")){%>
          <option value="0" selected>Server</option>
          <option value="1">Workstation</option>
          <%}else if (WI.getStrValue(strProcessor,"").equals("1")){%>
          <option value="0">Server</option>
          <option value="1" selected>Workstation</option>
          <%} else {%>
          <option value="0">Server</option>
          <option value="1">Workstation</option>
          <%}%>
        </select> </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Status</td>
      <td colspan="2"><%strTemp = WI.fillTextValue("stat_index");%> <select name="stat_index">
          <option value="">Select category</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status order by inv_status", strTemp, false)%> </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Warranty Date</td>
      <td colspan="4"> <%strTemp = WI.fillTextValue("warranty_fr");%> <input name="warranty_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.warranty_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("warranty_to");%> <input name="warranty_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.warranty_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
  </table>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
    <td colspan="6">&nbsp;</td>
    </tr>
    
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="20%">Sort by</td>
      <td width="24%">
	  <select name="sort_by1">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="25%"><select name="sort_by2">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="27%"><select name="sort_by3">
	 	<option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <br/>
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><font color="#FFFFFF"><strong> 
          INVENTORY REPORT </strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" class="thinborder"><strong><font size="1"> TOTAL 
        ITEM(S) : <%=iSearchResult%> - Showing(<%=InvSearch.getDisplayRange()%>)</font></strong></td>
      <td height="25" colspan="3" align="right" class="thinborderBOTTOM"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvSearch.defSearchSize;
		if(iSearchResult % InvSearch.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
        Jump To page: 
        <select name="jumpto" onChange="SearchNow();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%	}
			}
			%>
        </select> <%} else {%> &nbsp; <%}%></td>
    </tr>
    <tr> 
      <td width="8%" class="thinborder" align="center" height="25"><font size="1"><strong>PROPERTY 
        NUMBER</strong></font></td>
      <td width="25%" class="thinborder" align="center"><font size="1"><strong>ITEM 
        DETAILS</strong></font></td>
      <td width="19%" class="thinborder" align="center"><font size="1"><strong>OWNERSHIP</strong></font></td>
      <td width="21%" class="thinborder" align="center"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="13%" class="thinborder" align="center"><font size="1"><strong>ITEM 
        STATUS </strong></font></td>
      <td width="14%" class="thinborder" align="center"><font size="1"><strong>OTHER 
        DETAILS</strong></font></td>
    </tr>
    <%for (i = 0; i<vRetResult.size(); i+=11){%>
    <tr> 
      <td class="thinborder" align="center"><font size="1"> 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
			<%if (WI.fillTextValue("propnum").length() > 0) {%>
			    <a href='javascript:CopyPropNum("<%=WI.fillTextValue("propnum")+","+(String)vRetResult.elementAt(i)%>");'>
				<%=(String)vRetResult.elementAt(i)%></a>
			<%}else{%>
				<a href='javascript:CopyPropNum("<%=(String)vRetResult.elementAt(i)%>");'> 
		        <%=(String)vRetResult.elementAt(i)%></a> 
			<%}%>        
        <%}else{%>
	        <%=(String)vRetResult.elementAt(i)%> 
        <%}%>
        </font></td>
      <td height="25" class="thinborder"><font size="1"> &nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"Serial #: ","<br>","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"Product #: ","<br>","")%> </font></td>
      <td class="thinborder"><font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+1),"College: ","<br>","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"Department: ","","&nbsp;")%> </font></td>
      <td class="thinborder"><font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+3),"Building: ","<br>","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"Room: ","<br>","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"Description: ","","&nbsp;")%> </font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"")%></font></td>
      <td class="thinborder"><font size="1"> &nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"Warranty until: ","<br>","")%> </font></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="propnum" value="<%=WI.fillTextValue("propnum")%>">
  
  <!-- Instruction -- set the opner_from_name to the parent window to copy stuff -->
	<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
