<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);

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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function SearchList(){
	document.form_.searchlist.value = "1";
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	this.SubmitOnce('form_');
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyTransNum(strPropNum)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strPropNum;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	self.close();
}
<%}%>
</script>
</head>
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-INVENTORY MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY MAINTENANCE","search_comp_borrow.jsp");
	
	Vector vRetResult = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};

	String strBldgFr = null;
	String strBldgTo = null;
	String strCollegeFr = null;
	String strCollegeTo = null;
	Vector vItems = null;
	
	int iSearchResult = 0;	
	InvCPUMaintenance InvMaint = new InvCPUMaintenance();
	
	if (WI.fillTextValue("searchlist").length() > 0){
			vRetResult = InvMaint.searchBorrowComp(dbOP, request);

		if (vRetResult != null)
			iSearchResult = InvMaint.getSearchCount();
		else if (vRetResult == null)
			strErrMsg = InvMaint.getErrMsg();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="search_comp_borrow.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - VIEW BORROW ITEM(S) PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
    <tr> 
      <td height="30" align="center" width="3%">&nbsp;</td>
      <td width="19%"><strong>Borrow Number</strong></td>
      <td valign="middle"> <select name="borrow_con">
          <%=InvMaint.constructGenericDropList(WI.fillTextValue("borrow_con"),astrDropListEqual,astrDropListValEqual)%> </select>
		  <input type="text" name="borrow_no" value="<%=WI.fillTextValue("borrow_no")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td width="3%" height="30" align="center">&nbsp;</td>
      <td width="19%"><strong>Borrowed Date</strong></td>
      <td width="78%" valign="middle">From 
        <%strTemp = WI.fillTextValue("date_fr");%> <input name="date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("date_to");%> <input name="date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="30" align="center">&nbsp;</td>
      <td><strong>Reason for use</strong></td>
      <td valign="middle">
	  <%
	  	strTemp = WI.fillTextValue("reason_index");
	  %>
	  <select name="reason_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("trans_reason_index","reason"," from inv_preload_trans_reason order by reason", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="40" colspan="3"><div align="center"><a href="javascript:SearchList();"><img src="../../../images/form_proceed.gif" border="0"></a></div></td>
    </tr>
  </table>
	<%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="4" class="thinborder"><div align="center"> 
          <p><strong><font size="2">TRANSACTION DETAILS</font></strong></p>
        </div></td>
    </tr>
    <tr>
      <td  height="25" colspan="2" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td align="right" class="thinborderBOTTOM">&nbsp;</td>
      <td align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvMaint.defSearchSize;
		if(iSearchResult % InvMaint.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%> <select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%	}
			}// end page printing
			%>
        </select> <%} else {%> &nbsp; <%} //if no pages %></td>
    </tr>
    <tr> 
      <td width="19%" height="25" class="thinborder"><div align="center"><font size="1"><strong>BORROW 
          # </strong></font></div></td>
      <td width="34%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          NAME/PROPERTY NUMBER</strong></font></div></td>
      <td width="28%" align="center" class="thinborder"><font size="1"><strong>BORROWED 
        BY</strong></font></td>
      <td width="19%" align="center" class="thinborder"> <div align="center"><font size="1"><strong>DATE</strong></font></div>
        <div align="center"></div></td>
    </tr>
    <% 
	for (i = 0; i<vRetResult.size(); i+=13){
		vItems = (Vector)vRetResult.elementAt(i+12);		
	%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"> 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyTransNum("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%> 
        <%}%>
        </font></td>
      <td class="thinborder"><font size="1">
	  <%for(int j = 0;j < vItems.size(); j+=4){%>
	  	Item Name: <%=(String)vItems.elementAt(j)%> 
        <%=WI.getStrValue((String)vItems.elementAt(j+3),"(",")<br>","")%> 
	  <%}// end inner for loop%>
		
		</font></td>
      <td class="thinborder"><font size="1"> <%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"(",")","")%>	
        </font></td>
      <td class="thinborder"> <div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+11)%>&nbsp;</font></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<%if (vRetResult != null && vRetResult.size()>0){%>
    <tr>
      <td height="27"  colspan="3"><div align="center"></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg">
  <input type="hidden" name="searchlist">  
  <input type="hidden" name="item_type" value="<%=WI.fillTextValue("item_type")%>">
  <!-- Instruction -- set the opner_from_name to the parent window to copy stuff -->
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>