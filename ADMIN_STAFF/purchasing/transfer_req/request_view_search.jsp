<%@ page language="java" import="utility.*,inventory.InventorySearch,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();	

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
    document.form_.printPage.value = "";	
 	this.SubmitOnce('form_');
}
function ProceedClicked(){
    document.form_.printPage.value = "";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function ViewItem(strIndex){
	var pgLoc = "request_view.jsp?req_no="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strID)
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
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="request_view_search_print.jsp"/>
	<%return;}

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}				
	}
	
	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2;
		
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Search","request_view_search.jsp");
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
	
	InventorySearch InvSearch = new InventorySearch();
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
	String[] astrSortByVal     = {"req_number","request_date","requisition_status","c_code","d_name"};
	int iSearch = 0;
	int iDefault = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = InvSearch.searchTransferRequest(dbOP,request);
		if(vRetResult == null)
			strErrMsg = InvSearch.getErrMsg();
		else
			iSearch = InvSearch.getSearchCount();
	}	
%>
<form name="form_" method="post" action="request_view_search.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A">
			<td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
				REQUISITION : VIEW/SEARCH REQUISITIONS PAGE ::::</strong></font></div></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="24%">Requisition No. : </td>
      <td width="72%"><select name="req_no_select">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("req_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_num" class="textbox" value="<%=WI.fillTextValue("req_num")%>"
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
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("req_by_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_by" class="textbox" value="<%=WI.fillTextValue("req_by")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%> :</td>
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
	<!--
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
        Non-Supply 
        <%if(WI.fillTextValue("chemical").equals("2")|| 
	  (WI.fillTextValue("opner_info").length() > 1 && WI.fillTextValue("nsupply").equals("2")))
	 		strTemp = "checked";
		else
			strTemp = "";%>
        <input type="checkbox" name="chemical" value="2" <%=strTemp%>>
        Chemicals </td>
    </tr>
	-->
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="3"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="32%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="32%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="32%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=InvSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
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
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a>      </td>
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
	  <a href="javascript:PrintPage();">
	  <img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print list</font></div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=InvSearch.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/InvSearch.defSearchSize;
		double dTotalItems = 0d;
		if(iSearch % InvSearch.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
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
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUISITIONS</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td width="18%"  height="25"  class="thinborder"><div align="center"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/DEPT</strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>OFFICE</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>REQUISITION NO.</strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>DATE REQUESTED</strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>REQUESTED BY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>STATUS</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>TOTAL ITEMS </strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>VIEW</strong></div></td>
    </tr>
    <%for(int i = 0;i < vRetResult.size();i+=8){%>
    <tr> 
      <td height="25" class="thinborder"> <div align="left">
          <%if(((String)vRetResult.elementAt(i+5)) != null){%>
          <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"N/A") +"/"+ WI.getStrValue((String)vRetResult.elementAt(i+6),"All")%> 
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
      <td class="thinborder"> <div align="left">
          <%if(((String)vRetResult.elementAt(i+5)) != null){%>
          N/A 
          <%}else{%>
          <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%> 
          <%}%>
        </div></td>
      <td class="thinborder"> <div align="center">
          <%if(WI.fillTextValue("opner_info").length() > 0) {%>
          <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> 
          <%=(String)vRetResult.elementAt(i+1)%> </a> 
          <%}else{%>   
       	  <%=(String)vRetResult.elementAt(i+1)%>
          <%}%>
        </div></td class="thinborder">
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i + 4)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetResult.elementAt(i + 3)%></div></td>
      <td class="thinborder"><div align="left"><%=astrReqStatus[Integer.parseInt((String)vRetResult.elementAt(i+2))]%>
	  </div></td>
      <td class="thinborder"><div align="right">
          <%if(vRetResult.elementAt(i+7) == null || ((String)vRetResult.elementAt(i+7)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(i+7)%> 
          <%}%>
        </div></td>		
      <td class="thinborder"><div align="center">
	  <%if(WI.fillTextValue("opner_info").length() < 1) {%>
			<a href="javascript:ViewItem('<%=(String)vRetResult.elementAt(i+1)%>');">
		    <img src="../../../images/view.gif" border="0" ></a>
	  <%}else{%>
	  		N/A
	  <%}%>
	  
	  </div></td>
    </tr>	
    <%  if(((String)vRetResult.elementAt(i+7)) != null && ((String)vRetResult.elementAt(i+7)).length() > 0)
			dTotalItems += Double.parseDouble((String)vRetResult.elementAt(i+7));    		
	}%>
	<%if(WI.fillTextValue("opner_info").length() < 1) {%> 
    <tr> 
      <td height="25" colspan="6" align="right" class="thinborder"> <strong>PAGE TOTAL :&nbsp;&nbsp;&nbsp;</strong></td>
      <td class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalItems,false)%></strong></div></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
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
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>