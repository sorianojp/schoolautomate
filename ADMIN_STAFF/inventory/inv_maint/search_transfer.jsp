<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
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
	//alert("strPropNum " + strPropNum + "i");	
  //strPropNum = this != window? this : strPropNum;
	//alert("strPropNum " + strPropNum);	
	//strPropNum =  strPropNum.replace(/^\s+/g, '').replace(/\s+$/g, '');
  //return strPropNum.replace(/^\s+/g, '').replace(/\s+$/g, '');
	
	alert("strPropNum " + strPropNum + "i");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
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
								"INVENTORY-INVENTORY MAINTENANCE","search_transfer.jsp");
	
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
	
	int iSearchResult = 0;
	
	// note that the item type depends on what value is sent by the calling page... 
	InventorySearch InvSearch = new InventorySearch();

	if (WI.fillTextValue("searchlist").length() > 0){
		vRetResult = InvSearch.searchTransfer(dbOP, request);
		//System.out.println("entered here");
		if (vRetResult != null)
			iSearchResult = InvSearch.getSearchCount();
		else
			strErrMsg = InvSearch.getErrMsg();	  
	}	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="search_transfer.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - VIEW TRANSFERRED ITEM(S) PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="30" align="center" width="3%">&nbsp;</td>
      <td width="20%"><strong>Transfer Number</strong></td>
      <td colspan="2" valign="middle"> <select name="transfer_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("transfer_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="trans_no" value="<%=WI.fillTextValue("trans_no")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="36%" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td align="center">&nbsp;</td>
      <td><strong>Property Number</strong></td>
      <td colspan="2" valign="middle"><select name="prop_con">
          <%=InvSearch.constructGenericDropList(WI.fillTextValue("prop_con"),astrDropListEqual,astrDropListValEqual)%>
		   </select> <input type="text" name="prop_num" value="<%=WI.fillTextValue("prop_num")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td align="center">&nbsp;</td>
      <td><strong>Room From</strong></td>
      <td valign="middle"> <%strTemp2 = WI.fillTextValue("room_index_fr");%> <select name="room_index_fr">
          <option value="">N/A</option>
          <% strBldgFr = " from E_ROOM_DETAIL where " +
				" E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strBldgFr, strTemp2, false)%> </select></td>
      <td width="19%" valign="middle"><strong>Room To</strong></td>
      <td valign="middle"> <%strTemp2 = WI.fillTextValue("room_index_to");%> <select name="room_index_to">
          <option value="">N/A</option>
          <% strBldgTo = " from E_ROOM_DETAIL where " +
				" E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strBldgTo, strTemp2, false)%> </select></td>
    </tr>
    <tr> 
      <td height="30" align="center">&nbsp;</td>
      <td><strong>College From</strong></td>
      <td colspan="3" valign="middle"> <%strCollegeFr = WI.fillTextValue("c_index_fr");%> <select name="c_index_fr" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strCollegeFr, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="30" align="center">&nbsp;</td>
      <td><strong>Department From</strong></td>
      <td colspan="3" valign="middle"> <%strTemp2 = WI.fillTextValue("d_index_fr");%> <select name="d_index_fr">
          <% if(strCollegeFr!=null && strCollegeFr.compareTo("0") !=0){%>
          <option value="">All</option>
          <%} if (strCollegeFr == null || strCollegeFr.length() == 0 || strCollegeFr.compareTo("0") == 0) strCollegeFr = " and (c_index = 0 or c_index is null) ";
		else strCollegeFr = " and c_index = " +  strCollegeFr;%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strCollegeFr + " order by d_name asc",strTemp2, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="30" align="center">&nbsp;</td>
      <td><strong>College To</strong></td>
      <td colspan="3" valign="middle"> <%strCollegeTo = WI.fillTextValue("c_index_to");%> <select name="c_index_to" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strCollegeTo, false)%> </select></td>
    </tr>
    <tr> 
      <td height="30" align="center">&nbsp;</td>
      <td><strong>Department To</strong></td>
      <td colspan="3" valign="middle"> <%strTemp2 = WI.fillTextValue("d_index_to");%> <select name="d_index_to">
          <% if(strCollegeTo!=null && strCollegeTo.compareTo("0") !=0){%>
          <option value="">All</option>
          <%} if (strCollegeTo == null || strCollegeTo.length() == 0 || strCollegeTo.compareTo("0") == 0) strCollegeTo = " and (c_index = 0 or c_index is null) ";
		else strCollegeTo = " and c_index = " +  strCollegeTo;%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strCollegeTo + " order by d_name asc",strTemp2, false)%> </select></td>
    </tr>
    <tr> 
      <td width="3%" height="30" align="center">&nbsp;</td>
      <td width="20%"><strong>Transfer Date</strong></td>
      <td colspan="3" valign="middle">From 
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
      <td height="40" colspan="5"><div align="center"><a href="javascript:SearchList();"><img src="../../../images/form_proceed.gif" border="0"></a></div></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="7" class="thinborder"><div align="center"> 
          <p><strong><font size="2">TRANSFER DETAILS</font></strong></p>
        </div></td>
    </tr>
    <td  height="25" colspan="4" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
      ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
    <td colspan="3" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 15 default display per page)
		int iPageCount = iSearchResult/InvSearch.defSearchSize;
		if(iSearchResult % InvSearch.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
      <select name="jumpto" onChange="SearchList();" style="font-size:11px">
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
      </select> <%} else {%>
      &nbsp;
      <%} //if no pages %></td>
    </tr>
    <tr>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>TRANSFER 
          # </strong></font></div></td>
      <td width="9%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PROPERTY 
          # </strong></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          CATEGORY/NAME/SERIAL #/PRODUCT #</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>QTY 
          TRANSFERED </strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>ORIGINAL 
          LOCATION </strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>TRANSFER 
          LOCATION </strong></font></div></td>
      <td width="11%" align="center" class="thinborder"> <div align="center"><font size="1"><strong>DATE</strong></font></div>
        <div align="center"></div></td>
    </tr>
    <%for (i = 0; i<vRetResult.size(); i+=25){%>
    <tr>
      <td class="thinborder"><font size="1">
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href="javascript:CopyTransNum('<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+1),"'"," ")%>');"> 
        <%=(String)vRetResult.elementAt(i+1)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%> 
        <%}%>
        </font></td>
      <td class="thinborder" height="25"><font size="1">
        <%=(String)vRetResult.elementAt(i+2)%> 
        </font></td>
      <td class="thinborder"><font size="1"> Item Name: <%=(String)vRetResult.elementAt(i+3)%> 
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br>Product No: ","","")%> 
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<br>Serial No: ","","")%></font> </td>
      <td class="thinborder" align="center"> <font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"> 
		  <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"Room: ","","")%> 
		  <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"<br>Location: ","","")%> 
		  <%=WI.getStrValue((String)vRetResult.elementAt(i+21),"<br>College: ","","")%>
		  <%=WI.getStrValue((String)vRetResult.elementAt(i+23),"<br>Department: ","","&nbsp;")%>
	  </font></td>
      <td class="thinborder"> <font size="1"> 
		  <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"Room: ","","")%> 
		  <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"<br>Location: ","","")%> 
		  <%=WI.getStrValue((String)vRetResult.elementAt(i+22),"<br>College: ","","")%>	
		  <%=WI.getStrValue((String)vRetResult.elementAt(i+24),"<br>Department: ","","&nbsp;")%>
	  </font></td>
      <td class="thinborder"> <div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"&nbsp;")%></font></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<%if (vRetResult != null && vRetResult.size()>0){%>
    <tr>
      <td height="46"  colspan="3"><div align="center"></div></td>
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