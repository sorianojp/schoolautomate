<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
	///added code for school/companies.
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
function OpenSearchPO(){
	var pgLoc = "../canvassing/canvassing_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function QuoteItem(strQuote,strIndex,strReqIndex,strInfoIndex,strIsCredited, strInvCat){
    document.form_.printPage.value = "";
	if(strQuote == 0)
		var pgLoc = "./quotation_encode_pop_up.jsp?req_item_index="+strIndex+"&encode_pop=1&req_index="+strReqIndex+
								"&is_credited="+strIsCredited+"&cat_index="+strInvCat;
	else if(strQuote == 1)
		var pgLoc = "./quotation_encode_pop_up_additional_cost.jsp?req_index="+strReqIndex;		
	else
		var pgLoc = "./quotation_encode_pop_up_additional_cost.jsp?req_index="+strReqIndex+"&page_action=3&info_index="+
		strInfoIndex+"&supplier="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",  'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function PageLoad(){
	document.form_.req_no.focus();
}
function DeleteCost(strIndex,strDelete){
	if(!confirm('Delete '+strDelete+'?'))
		return;
	document.form_.delete_cost.value = 1;
	document.form_.info_index.value = strIndex;
	this.SubmitOnce('form_');
}
</script>
<%
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./quotation_encode_print.jsp"/>
	<%}
    //authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-QUOTATION"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-QUOTATION","quotation_encode.jsp");
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqItemsPO = null;
	Vector vReqItemsQtn = null;
	Vector vSupplierList = new Vector();
	
	
	String strErrMsg = null;
	String strTemp  = null;
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strHasItems = WI.getStrValue(WI.fillTextValue("has_credited"),"");
	String strSchCode = dbOP.getSchoolIndex();
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String strInfoIndex = WI.fillTextValue("info_index");
	int iLoop = 0;
	int iCount = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		if(WI.fillTextValue("delete_cost").length() > 0){
			vReqInfo = QTN.operateOnAdditionalCost(dbOP,request,0);
			if(vReqInfo == null)
				strErrMsg = QTN.getErrMsg();
			else
				strErrMsg = "Operation Successful.";				
		}
		vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request);
		if(vReqInfo == null)
			strErrMsg = QTN.getErrMsg();
		else{
			strInfoIndex = (String)vReqInfo.elementAt(0);//requisition_index
			vRetResult = QTN.operateOnReqItemsQtn(dbOP,request,4,strInfoIndex);
			if(vRetResult == null)
				strErrMsg = QTN.getErrMsg();
			else{
				vReqItemsPO = (Vector)vRetResult.elementAt(0);
				vReqItemsQtn = (Vector)vRetResult.elementAt(1);				
			}				
		}				
	}
%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="quotation_encode.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          QUOTATION - ENCODE QUOTATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="29%">Canvass No. :</td>
      <td width="27%"><%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp1 = WI.fillTextValue("req_no");
	    }else{
	  		strTemp1 = "";
        }%>
        <input type="text" name="req_no" class="textbox" value="<%=strTemp1%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="41%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search canvass no.</font></td>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> 
	  <%if(strSchCode.startsWith("CPU")){//Show only for end users who want to have budget approval%>
	  <%if(vReqInfo != null && vReqInfo.size() > 2 && vReqItemsQtn != null && vReqItemsQtn.size() > 3){%>  
		  <%if(vReqInfo.elementAt(3) != null && ((String)vReqInfo.elementAt(3)).trim().length() > 0){%>
		  <a href="quotation_request_update_for_approval.jsp?proceedClicked=1&req_no=<%=vReqInfo.elementAt(3)%>">Click 
			here for Budget approval</a> 
		  <%}%>
	  <%}%>
	  <%}%>
		&nbsp; </td>
      <td height="25"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"> </a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%if(vReqInfo != null && vReqInfo.size() > 2){%>
    <tr>
      <td height="25">
      <td>Canvass No. :<strong><%=vReqInfo.elementAt(1)%></strong></td>
      <td><div align="center">Canvass Date : <strong><%=vReqInfo.elementAt(2)%></strong> </div></td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="19" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR  CANVASS NO : <%=vReqInfo.elementAt(1)%></strong></div></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=vReqInfo.elementAt(3)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"><strong><%=vReqInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(5))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(7))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(9)) == null){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="19" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <%if(vReqItemsPO != null && vReqItemsPO.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" bgcolor="#B9B292" colspan="9" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUISITION ITEM(S) WITHOUT QUOTATION</strong></font></div></td>
    </tr>
    <tr>
      <td width="6%"  height="27" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="39%" class="thinborder"><div align="center"><strong>PARTICULARS/ITEM 
          DESCRIPTION</strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>QUOTE</strong></div></td>
    </tr>
    <%for(iLoop = 0,iCount=1;iLoop < vReqItemsPO.size();iLoop += 7,++iCount){%>
    <tr>
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItemsPO.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsPO.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsPO.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsPO.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="center"> 
			<a href="javascript:QuoteItem('0','<%=(String)vReqItemsPO.elementAt(iLoop)%>','<%=strInfoIndex%>',
			'','1','<%=(String)vReqItemsPO.elementAt(iLoop+5)%>')"> <img src="../../../images/openfile.gif" border="0" height="25"> </a> </div></td>
    </tr>
    <%}%>
    <tr>
      <td height="25" colspan="6" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%">
    <tr>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}if(vReqItemsQtn != null && vReqItemsQtn.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="9" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUISITION ITEM(S) WITH QUOTATION</strong></font></div></td>
    </tr>
    <tr> 
      <td width="4%" height="26" class="thinborder"><div align="center"><font size="1"><strong>QTY</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>UNIT</strong></font></div></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          / PARTICULARS / DESCRIPTION </strong></font></div></td>
      <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>SUPPLIER 
          CODE </strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>PRICE 
          QUOTED</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>DISCOUNT</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>UNIT 
          PRICE</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          AMOUNT</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>MODIFY</strong></font></div></td>
    </tr>
    <% strHasItems = "";
	for(iLoop = 0,iCount = 1;iLoop < vReqItemsQtn.size();iLoop+=17,++iCount){
		if((String)vReqItemsQtn.elementAt(iLoop+4) != null){
			strHasItems = "1";			
		}
	%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vReqItemsQtn.elementAt(iLoop)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+2)%> / <%=(String)vReqItemsQtn.elementAt(iLoop+3)%></div></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+4),"","",(String)vReqItemsQtn.elementAt(iLoop+14));
	  
	  if(vSupplierList.indexOf(strTemp) == -1)
	  	vSupplierList.addElement(strTemp);
	  
	  %>	       
      <td class="thinborder"><div align="left"><%=strTemp%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+13),"(",")","")%> 
          <%
			strTemp1 = "";
			strTemp2 = "";
			strTemp3 = "";
			strErrMsg = "";			
			for(; (iLoop + 17) < vReqItemsQtn.size() ;){
			 //System.out.println("9 " +(String)vReqItemsQtn.elementAt(iLoop+9));
			 //System.out.println("22 " +(String)vReqItemsQtn.elementAt(iLoop+22));
			 if(!(((String)vReqItemsQtn.elementAt(iLoop+9)).equals((String)vReqItemsQtn.elementAt(iLoop + 26))))
					break;
			 if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false) + "% <br>";
				
          	 }else{
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true) +
							astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+12))] + "<br>";
          	 }
			
			 strErrMsg += (String)vReqItemsQtn.elementAt(iLoop+5) + 
			 			   astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]+ "<br>";
			 strTemp2 += (String)vReqItemsQtn.elementAt(iLoop + 8) + "<br>";
			 strTemp3 += (String)vReqItemsQtn.elementAt(iLoop + 11) + "<br>";
			 %>
          <br>
          <%//=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop + 15 + 4),"","","(uncredited)"+(String)vReqItemsQtn.elementAt(iLoop + 15 + 14))%><%//=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+15 + 13),"(",")","")%> 
		  <%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop + 17 + 4),"","",(String)vReqItemsQtn.elementAt(iLoop + 17 + 14))%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop + 17 + 13),"(",")","")%> 
          <%iLoop += 17;}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strErrMsg + (String)vReqItemsQtn.elementAt(iLoop+5)+
	  		astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]%></div></td>
      <td class="thinborder"><div align="right"> <%=strTemp1%> 
          <%if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false)%>% 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true)+
		     astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+12))]%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strTemp3 + (String)vReqItemsQtn.elementAt(iLoop+11)%></div></td>
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
		<%
			if(vReqItemsQtn.elementAt(iLoop+4) == null)
				strTemp1 = "0";
			else
				strTemp1 = "1";
		%>
      <td class="thinborder"><div align="center"><a href="javascript:QuoteItem('0','<%=(String)vReqItemsQtn.elementAt(iLoop+9)%>',
	  '<%=strInfoIndex%>','','<%=strTemp1%>','<%=(String)vReqItemsQtn.elementAt(iLoop+15)%>')">
		<img src="../../../images/openfile.gif" border="0" height="25"></a></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%">
    <tr>
      <td>&nbsp;</td>
	</tr>
    <tr>
      <td><div align="center"><font size="1">
	  <a href="javascript:QuoteItem('1','','<%=strInfoIndex%>','','1')">
	  <img src="../../../images/openfile.gif" border="0" height="25"></a>
	  click to encode <strong>ADDITIONAL COST</strong> (ex. shipping, 
          tax, handling cost)</font></div></td>    
    </tr>
  </table>
  <%if(vRetResult.size() > 2){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>ADDITIONAL 
          COST FOR THIS QUOTATION</strong></font></div></td>
    </tr>
    <tr>
      <td width="35%" class="thinborder"><div align="center"><strong>SUPPLIER 
          NAME</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>COST 
      NAME </strong></div></td>
      <td width="28%" height="25" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>EDIT</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>DELETE</strong></div></td>
    </tr>
	<%for(iLoop = 2;iLoop < vRetResult.size();iLoop+=5){%>
    <tr>
      <td  height="25" class="thinborder"><%=vRetResult.elementAt(iLoop+2)%>
	  <%/*strTemp1 = "";
	  	strTemp2 = "";
	  for(;(iLoop+3+5) < vRetResult.size();){
	  		if(!((String)vRetResult.elementAt(iLoop+1)).equals((String)vRetResult.elementAt(iLoop+1+5)))
	  			break;
			strTemp1 += (String)vRetResult.elementAt(iLoop+3)+"<br>";
			strTemp2 += (String)vRetResult.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }*/%>
	  </td>
      <td class="thinborder"><%=/*strTemp1+*/(String)vRetResult.elementAt(iLoop+3)%></td>
      <td class="thinborder"><div align="right"><%=/*strTemp2+*/(String)vRetResult.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="center">
	  <a href="javascript:QuoteItem('2','<%=vRetResult.elementAt(iLoop+1)%>','<%=strInfoIndex%>',
	  '<%=vRetResult.elementAt(iLoop)%>','1')">
	  <img src="../../../images/edit.gif" border="0"></a>
	  </div></td>
      <td class="thinborder"><div align="center">
	  <a href="javascript:DeleteCost('<%=vRetResult.elementAt(iLoop)%>',
	  '<%=(String)vRetResult.elementAt(iLoop+2)+"("+(String)vRetResult.elementAt(iLoop+3)+")"%>');">
	  <img src="../../../images/delete.gif" border="0"></a></div></td>
    </tr>
	<%}%>
  </table>
  <%}
  }if((vReqItemsPO != null && vReqItemsPO.size() > 3) || (vReqItemsQtn != null && vReqItemsQtn.size() > 3)){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="center"> 
	  <%
	  if(vSupplierList.size() > 1){
	  %>
	  <select name="supplier_index">
	  	<option value="">All</option>
	  	<%
		strTemp = 
			" from PUR_QUOTATION "+
			" join PUR_SUPPLIER_PROFILE on (PUR_SUPPLIER_PROFILE.PROFILE_INDEX = PUR_QUOTATION.SUPPLIER_INDEX) "+
			" join PUR_REQUISITION_INFO on (PUR_REQUISITION_INFO.REQUISITION_INDEX = PUR_QUOTATION.REQUISITION_INDEX) "+
			" where CANVASS_NO = "+WI.getInsertValueForDB(WI.fillTextValue("req_no"), true, null)+
			" and PUR_QUOTATION.IS_DEL = 0 "+
			" and PUR_REQUISITION_INFO.IS_DEL = 0 ";
		%>
		<%=dbOP.loadCombo("distinct supplier_index", "supplier_code, supplier_name", strTemp, WI.fillTextValue("supplier_index"), false)%>
	  </select>
	  <input type="hidden" name="no_of_supplier" value="<%=vSupplierList.size()%>">
	  <%}%>
	  
	  <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print this details</font></div></td>
    </tr>
  </table>
  <%}}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="printPage">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="delete_cost" >
  <input type="hidden" name="has_credited" value="<%=strHasItems%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
