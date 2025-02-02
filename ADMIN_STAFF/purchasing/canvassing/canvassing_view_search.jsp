<%@ page language="java" import="utility.*,purchasing.Canvassing,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	String strFormName2 = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	java.util.StringTokenizer strToken2 = new java.util.StringTokenizer(WI.fillTextValue("is_supply"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();	
	if(strToken2.hasMoreElements())
		strFormName2 = strToken2.nextToken();	
	///added code for HR/companies.
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View / Search Requisition</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ReloadPage(){	
    document.form_.print_pg.value = "";	
 	this.SubmitOnce('form_');
}
function ProceedClicked(){
    document.form_.print_pg.value = "";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function ViewItem(strReqNo,strIndex,strSupply,strDate){
//	var pgLoc = "./canvass_view.jsp?req_no="+strReqNo+"&canvass_no="+strIndex+"+&is_supply="+strSupply+
//	"&is_canvass=1&canvass_date="+strDate;
	var pgLoc = "./canvass_view2.jsp?req_no="+strReqNo+"&canvass_no="+strIndex+"+&is_supply="+strSupply+
	"&is_canvass=1&canvass_date="+strDate;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
function PrintPg(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strID,strIndex)
{
	window.opener.document.<%=strFormName%>.proceedClicked.value=1;
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strID;	
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();	
	<%}%>	
	self.close();
}
<%}%>
</script>
<body bgcolor="#D2AE72">
<%
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="./canvassing_view_search_print.jsp"/>
	<%return;}
	DBOperation dbOP = null;
//add security here.
/**
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-CANVASSING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
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
**/
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-CANVASSING-Canvassing View Search","canvassing_view_search.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Canvassing CAN = new Canvassing();
	Vector vRetResult = null;		
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String strCollDiv = null;
	if(bolIsSchool)
		 strCollDiv = "College";
	else
		 strCollDiv = "Division";
		 
	String[] astrSortByName    = {"Requisition No.","Requisition Date","Requisition Status",strCollDiv,"Department"};
	String[] astrSortByVal     = {"REQUISITION_NO","REQUEST_DATE","REQUISITION_STATUS","C_CODE","D_NAME"};
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iSearch = 0;
	int iDefault = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = CAN.searchCanvass(dbOP,request);
		if(vRetResult == null)
			strErrMsg = CAN.getErrMsg();
		else
			iSearch = CAN.getSearchCount();
	}
%>
<form name="form_" method="post" action="./canvassing_view_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CANVASSING - SEARCH/VIEW REQUISITION FOR CANVASSING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="24%">Canvassing No.: </td>
      <td width="72%">
	  <select name="can_no_select">
          <%=CAN.constructGenericDropList(WI.fillTextValue("can_no_select"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
	  <input type="text" name="can_num" class="textbox" value="<%=WI.fillTextValue("can_num")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Canvassing Date : </td>
      <td>From:&nbsp; 
	  <input name="date_can_fr" type="text" value="<%=WI.fillTextValue("date_can_fr")%>" size="12" 
	  readonly="yes"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_can_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To:&nbsp; 
		<input name="date_can_to" value="<%=WI.fillTextValue("date_can_to")%>" type="text" class="textbox" size="12" readonly="yes"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_can_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Requisition No. : </td>
      <td><select name="req_no_select">
          <%=CAN.constructGenericDropList(WI.fillTextValue("req_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_num" class="textbox" value="<%=WI.fillTextValue("req_num")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Requisition Date :</td>
      <td>From:&nbsp; <input name="date_req_fr" type="text" value="<%=WI.fillTextValue("date_req_fr")%>" size="12" readonly="yes"  class="textbox"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_req_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To:&nbsp; <input name="date_req_to" value="<%=WI.fillTextValue("date_req_to")%>" type="text" class="textbox" size="12" readonly="yes"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_req_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Requested Status : </td>
      <td> <select name="req_status">
          <option value="">All</option>
          <%if(WI.fillTextValue("req_status").equals("1")){%>
          <option value="0">Disapproved</option>
          <option value="1" selected>Approved</option>
          <option value="2">Pending</option>
          <%}else if(WI.fillTextValue("req_status").equals("0")){%>
          <option value="0" selected>Disapproved</option>
          <option value="1">Approved</option>
          <option value="2">Pending</option>
          <%}else if(WI.fillTextValue("req_status").equals("2")){%>
          <option value="0">Disapproved</option>
          <option value="1">Approved</option>
          <option value="2" selected>Pending</option>
          <%}else{%>
          <option value="0">Disapproved</option>
          <option value="1">Approved</option>
          <option value="2">Pending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Requested By :</td>
      <td><select name="req_by_select">
          <%=CAN.constructGenericDropList(WI.fillTextValue("req_by_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_by" class="textbox" value="<%=WI.fillTextValue("req_by")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Level of Urgency :</td>
      <td> <select name="urgency">
          <option value="">All</option>
          <%if(WI.fillTextValue("urgency").equals("0")){%>
          <option value="0" selected>Low</option>
          <option value="2">High</option>
          <option value="1">Normal</option>
          <%}else if(WI.fillTextValue("urgency").equals("2")){%>
          <option value="0">Low</option>
          <option value="2" selected>High</option>
          <option value="1">Normal</option>
          <%}else if(WI.fillTextValue("urgency").equals("1")){%>
          <option value="0">Low</option>
          <option value="2">High</option>
          <option value="1" selected>Normal</option>
          <%}else{%>
          <option value="0">Low</option>
          <option value="2">High</option>
          <option value="1">Normal</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%=strCollDiv%> :</td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%if(WI.fillTextValue("c_index").equals("0")){%>
          <option value="0" selected>Non-Academic Office</option>
          <%}else{%>
          <option value="0">Non-Academic Office</option>
          <%} 
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp = WI.fillTextValue("c_index");
			else
				strTemp = "0";
			
			if(strTemp.compareTo("0") ==0)
				strTemp2 = "Offices";
			else
			strTemp2 = "Department";
			%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td> <%String strTemp3 = null;
		if(strTemp.compareTo("0") ==0) //only if non college show others.
			strTemp2 = " onChange='ShowHideOthers(\"d_index\",\"oth_dept\",\"dept_\");'";
		else
			strTemp2 = "";
	  %> <select name="d_index">
          <option value="0">All</option>
          <%if(WI.fillTextValue("c_index").length() < 1)
		 	strTemp="-1";
		 strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Request For :</td>
      <td height="25"> 
        <%if(WI.fillTextValue("supply").equals("1") || 
	  (WI.fillTextValue("opner_info").length() > 1 && WI.fillTextValue("nsupply").equals("1")))
	  		strTemp = "checked";
		else
			strTemp = "";%>
        <input type="checkbox" name="supply" value="1" <%=strTemp%>>
        Supply 
        <%if(WI.fillTextValue("non-supply").equals("0")|| 
	  (WI.fillTextValue("opner_info").length() > 1 && WI.fillTextValue("nsupply").equals("0")))
	 		strTemp = "checked";
		else
			strTemp = "";%>
	  <input type="checkbox" name="non-supply" value="0" <%=strTemp%>>
	    Non-Supply</td>
    </tr>
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="0" height="26">&nbsp;</td>
      <td colspan="5"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="20%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=CAN.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="20%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=CAN.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="20%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=CAN.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="20%"><select name="sort_by4">
          <option value="">N/A</option>
          <%=CAN.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="20%"><select name="sort_by5">
          <option value="">N/A</option>
          <%=CAN.constructSortByDropList(WI.fillTextValue("sort_by5"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
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
      <td><select name="sort_by5_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by5_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="5">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="5"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a> 
      </td>
    </tr>    
  </table>
  <%if(vRetResult != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
  <%if(WI.fillTextValue("opner_info").length() < 1) {%>   
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of Items / Supplies 
          Per Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
	  <a href="javascript:PrintPg();">
	  <img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print list</font></div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=CAN.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/CAN.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % CAN.defSearchSize > 0) ++iPageCount;		
		if(iPageCount >= 1)
		{%>
		&nbsp;</td>
		
      <td> <div align="right">Jump to page: 
          <select name="jumpto" onChange="ProceedClicked();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
				}
			}
		%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST OF REQUESTED ITEMS / SUPPLIES FOR CANVASSING</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td width="13%"  height="25"  class="thinborder"><div align="center"><strong><%=strCollDiv.toUpperCase()%>/DEPT</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>OFFICE</strong></div></td>
      <td width="18%" class="thinborder"><div align="center"><strong>REQUISITION NO. / CANVASSING NO</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>DATE REQUESTED / CANVASSING DATE</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>REQUESTED BY</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>STATUS</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>TOTAL ITEMS </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>VIEW</strong></div></td>
    </tr>
    <%for(int iLoop = 1;iLoop < vRetResult.size();iLoop+=13){%>
    <tr> 
      <td height="25" class="thinborder"> <div align="left">
          <%if(((String)vRetResult.elementAt(iLoop)) != null){%>
          <%=WI.getStrValue((String)vRetResult.elementAt(iLoop),"N/A") +"/"+ WI.getStrValue((String)vRetResult.elementAt(iLoop+1),"All")%> 
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
      <td class="thinborder"> <div align="left">
          <%if(((String)vRetResult.elementAt(iLoop)) != null){%>
          N/A 
          <%}else{%>
          <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+1),"&nbsp;")%> 
          <%}%>
        </div></td>
      <td class="thinborder"> <div align="center">
          <%if(WI.fillTextValue("opner_info").length() > 0) {%>
          <a href="javascript:CopyID('<%=vRetResult.elementAt(iLoop+11)%>','<%=vRetResult.elementAt(iLoop+10)%>');"> 
          <%=vRetResult.elementAt(iLoop+2)%> /<br> <%=vRetResult.elementAt(iLoop+11)%></a>
          <%}else{%>   
       	  <%=vRetResult.elementAt(iLoop+2)%> /<br> <%=vRetResult.elementAt(iLoop+11)%>
          <%}%>
        </div></td class="thinborder">
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+3)%> /<br>
	   <%=vRetResult.elementAt(iLoop+12)%>
	  </div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetResult.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="left"><%=astrReqStatus[Integer.parseInt((String)vRetResult.elementAt(iLoop+5))]%></div></td>
      <td class="thinborder"> <div align="right">
         <%if(vRetResult.elementAt(iLoop+6) == null || ((String)vRetResult.elementAt(iLoop+6)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(iLoop+6)%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right">
	 <%if(vRetResult.elementAt(iLoop+7) == null || ((String)vRetResult.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+7),true)%>
		<%}%>
	  </div></td>
      <td class="thinborder"><div align="center">
	  <%if(WI.fillTextValue("opner_info").length() < 1) {%>
		<a href="javascript:ViewItem('<%=vRetResult.elementAt(iLoop+2)%>','<%=vRetResult.elementAt(iLoop+11)%>',
		'<%=vRetResult.elementAt(iLoop+10)%>','<%=(String)vRetResult.elementAt(iLoop+12)%>');">
		    <img src="../../../images/view.gif" border="0" ></a>
	  <%}else{%>
	  		N/A
	  <%}%>
	  </div></td>
    </tr>	
    <%  if(((String)vRetResult.elementAt(iLoop+6)) != null && ((String)vRetResult.elementAt(iLoop+6)).length() > 0)
			dTotalItems += Double.parseDouble((String)vRetResult.elementAt(iLoop+6));    
		
		if(((String)vRetResult.elementAt(iLoop+7)) != null && ((String)vRetResult.elementAt(iLoop+7)).length() > 0)
			dTotalAmount += Double.parseDouble((String)vRetResult.elementAt(iLoop+7));		
	}%>
	<%if(WI.fillTextValue("opner_info").length() < 1) {%> 
    <tr> 
      <td height="25" colspan="6" class="thinborder"> <div align="right"><strong>PAGE TOTAL :&nbsp;&nbsp;&nbsp;</strong></div></td>
      <td class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalItems,false)%></strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong></div></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <td  class="thinborder" height="25" colspan="6"><div align="left"></div>
        <div align="right"><strong>OVERALL SEARCH TOTAL :&nbsp;&nbsp;&nbsp;</strong></div></td>
    <td height="25" colspan="2"  class="thinborder"><div align="right"></div>
      <div align="right"><strong><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(0),"0"),true)%></strong></div></td>
    <td class="thinborder">&nbsp;</td>
	<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>    
  </table>
<%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>