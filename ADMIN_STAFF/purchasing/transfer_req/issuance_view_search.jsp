<%@ page language="java" import="utility.*,inventory.InventorySearch,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();	
	
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
	var pgLoc = "issuance_details_view.jsp?issuance_index="+strIndex;
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
//	window.opener.document.<%=strFormName%>.proceedClicked.value=1;
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strID;
	window.opener.focus();
	<%
	//if(strFormName != null){%>
	//window.opener.document.<%=strFormName%>.submit();	
	<%//}%>	
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
		<jsp:forward page="issuance_view_search_print.jsp"/>
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Search","issuance_view_search.jsp");
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
	int iSearch = 0;
	int iDefault = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = InvSearch.searchIssuances(dbOP,request);
		if(vRetResult == null)
			strErrMsg = InvSearch.getErrMsg();
		else
			iSearch = InvSearch.getSearchCount();
	}	
%>
<form name="form_" method="post" action="issuance_view_search.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A">
			<td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
			ISSUANCE : VIEW/SEARCH ISSUANCE PAGE ::::</strong></font></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Requisition No. : </td>
      <td><select name="req_no_select">
        <%=InvSearch.constructGenericDropList(WI.fillTextValue("req_no_select"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input type="text" name="req_num" class="textbox" value="<%=WI.fillTextValue("req_num")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="24%">Issuance No. : </td>
      <td width="72%"><select name="issue_no_select">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("issue_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
					<input type="text" name="issuance_no" class="textbox" value="<%=WI.fillTextValue("issuance_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Issue Date :</td>
      <td>From:&nbsp; <input name="date_fr" type="text" value="<%=WI.fillTextValue("date_fr")%>" size="12" readonly="yes"  class="textbox"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To:&nbsp; <input name="date_to" value="<%=WI.fillTextValue("date_to")%>" type="text" class="textbox" size="12" readonly="yes"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>  
    <tr> 
      <td height="22" colspan="3">&nbsp;</td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="96%" colspan="3"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a>      </td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>    
  </table>
  <%if(vRetResult != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
  <%if(WI.fillTextValue("opner_info").length() < 1) {%>   
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of records  
          per page: 
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
      <td width="100%" height="25" align="center" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><font color="#FFFFFF"><strong>LIST 
      OF ISSUANCES</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td width="20%" height="25" align="center" class="thinborder"><strong>ISSUANCE NO.</strong></td>
      <td width="20%" align="center" class="thinborder"><strong>DATE ISSUED </strong></td>
      <td width="38%" align="center" class="thinborder"><strong>RECEIVED BY </strong></td>
      <td width="22%" align="center" class="thinborder"><strong>VIEW</strong></td>
    </tr>
    <%for(int i = 0;i < vRetResult.size();i+=5){%>
    <tr> 
      <td height="25" align="center" class="thinborder"> 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%> </a> 
        <%}else{%>   
     	  <%=(String)vRetResult.elementAt(i+1)%>
        <%}%>        </td class="thinborder">
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%></td>
      <td class="thinborder"><div align="center">
	  <%if(WI.fillTextValue("opner_info").length() < 1) {%>
			<a href="javascript:ViewItem('<%=(String)vRetResult.elementAt(i)%>');">
		    <img src="../../../images/view.gif" border="0" ></a>
	  <%}else{%>
	  		N/A
	  <%}%>
	  
	  </div></td>
    </tr>	
    <%   
	}%>
	<%if(WI.fillTextValue("opner_info").length() < 1) {%> 
    
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